Set-Location $PSScriptRoot
$path = Join-Path $PSScriptRoot 'publish-daily-v4-seo.ps1'
$bytes = [System.IO.File]::ReadAllBytes($path)
Write-Host "Byte length: $($bytes.Length)"
Write-Host "First bytes:" ($bytes[0..3] -join ', ')
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$pattern = 'Write-ColorOutput "Deployed!" "Green"'
$idx = $text.IndexOf($pattern)
Write-Host "idx=$idx"
if ($idx -ge 0) {
    $start = [Math]::Max(0, $idx-40)
    $end = [Math]::Min($text.Length-1, $idx+60)
    $frag = $text.Substring($start, $end-$start)
    Write-Host "frag=[${frag}]"
    $frag.ToCharArray() | ForEach-Object { $c = $_; $code = [int]$c; if ($code -lt 32 -or $code -gt 126) { Write-Host $code ('0x{0:X2}' -f $code) } }
    Write-Host "---- LINE CONTEXT ----"
    $lines = Get-Content -Path $path
    for ($i = 0; $i -le 132; $i++) {
        $line = $lines[$i]
        $quoteCount = ($line -split '"').Count - 1
        if ($i -ge 0 -and $i -le 132) {
            Write-Host "Line $($i+1): ($quoteCount quotes) $line"
            if ($i -eq 128) {
                $bytesLine = [System.Text.Encoding]::UTF8.GetBytes($line)
                Write-Host "Bytes:" ($bytesLine -join ', ')
            }
        }
    }
        # Cumulative check
        $lines = Get-Content -Path $path
        $cum = 0
        for ($i=0; $i -lt $lines.Count; $i++) {
            $cnt = ($lines[$i] -split '"').Count - 1
            $cum += $cnt
            if ($cum % 2 -ne 0) {
                Write-Host "Cumulative odd quotes at line $($i+1) (cum=$cum)"
                break
            }
        }
}

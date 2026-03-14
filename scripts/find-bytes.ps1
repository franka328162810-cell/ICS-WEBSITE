param([byte[]]$pattern)
$path = Join-Path $PSScriptRoot '..\public\zh\daily-commentary.html'
$bytes = [System.IO.File]::ReadAllBytes($path)
for ($i=0; $i -le $bytes.Length - $pattern.Length; $i++) {
    $match = $true
    for ($j=0; $j -lt $pattern.Length; $j++) {
        if ($bytes[$i+$j] -ne $pattern[$j]) { $match = $false; break }
    }
    if ($match) {
        $start = [Math]::Max(0, $i-20)
        $end = [Math]::Min($bytes.Length-1, $i+100)
        $segment = $bytes[$start..$end]
        Write-Host "Found at byte $i"
        Write-Host ([string]::Join(' ', $segment | ForEach-Object { '{0:X2}' -f $_ }))
        break
    }
}

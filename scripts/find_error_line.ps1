param([string]$file='publish-research-v4-seo.ps1')
$path = Join-Path $PSScriptRoot $file
$lines = Get-Content -Path $path -Encoding UTF8
$low = 1; $high = $lines.Count
while ($low -le $high) {
    $mid = [int](($low + $high) / 2)
    $content = ($lines[0..($mid-1)] -join "`n")
    $errors = [ref]@()
    try {
        [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, $errors) | Out-Null
    } catch {
        # ignore
    }
    if ($errors.Value.Count -gt 0) {
        $high = $mid - 1
        $firstError = $mid
    } else {
        $low = $mid + 1
    }
}
if ($firstError) { Write-Host "First parse error occurs by line: $firstError" } else { Write-Host 'No parse error found in prefixes' }

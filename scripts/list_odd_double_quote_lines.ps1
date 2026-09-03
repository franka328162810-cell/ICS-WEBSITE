param([string]$file='publish-research-v4-seo.ps1')
$path = Join-Path $PSScriptRoot $file
$lines = Get-Content -Path $path -Encoding UTF8
for ($i=0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    $cnt = ($line -split '"').Count - 1
    if ($cnt % 2 -ne 0) { Write-Host ('{0:D3}: ({1,2}) {2}' -f ($i+1), $cnt, $line) }
}
Write-Host 'Done'

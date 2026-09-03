param([string]$file='publish-research-v4-seo.ps1',[int]$start=130,[int]$end=150)
$path = Join-Path $PSScriptRoot $file
$lines = Get-Content -Path $path -Encoding UTF8
for ($i=$start; $i -le $end; $i++) { if ($i -le $lines.Count) { Write-Host ('{0:D3}: {1}' -f $i, $lines[$i-1]) } }

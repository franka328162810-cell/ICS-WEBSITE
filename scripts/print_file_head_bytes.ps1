param([string]$file='publish-research-v4-seo.ps1')
$path = Join-Path $PSScriptRoot $file
$bytes = [System.IO.File]::ReadAllBytes($path)
Write-Host "First bytes: $($bytes[0..2] -join ', ')"

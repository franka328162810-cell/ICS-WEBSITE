Set-Location $PSScriptRoot
$path = Join-Path $PSScriptRoot 'publish-daily-v4-seo.ps1'
$text = Get-Content -Path $path -Raw
Set-Content -Path $path -Value $text -Encoding UTF8
$bytes = [System.IO.File]::ReadAllBytes($path)
Write-Host "Rewrote $path with UTF8; first bytes: $($bytes[0..2] -join ', ')"

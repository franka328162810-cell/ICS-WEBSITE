param([string]$file)
$path = Join-Path $PSScriptRoot $file
$text = Get-Content -Raw -Path $path
Set-Content -Path $path -Value $text -Encoding UTF8
$bytes = [System.IO.File]::ReadAllBytes($path)
Write-Host "Rewrote $path; first bytes: $($bytes[0..2] -join ', ')"

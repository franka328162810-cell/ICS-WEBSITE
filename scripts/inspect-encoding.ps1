param(
    [string]$FilePath = "..\public\zh\daily-commentary.html"
)

$path = Join-Path $PSScriptRoot $FilePath
$bytes = Get-Content -Path $path -Encoding Byte -TotalCount 4
Write-Host "File: $path"
Write-Host "First 4 bytes:" ($bytes | ForEach-Object { '{0:X2}' -f $_ })

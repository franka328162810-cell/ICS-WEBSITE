param(
    [string]$Path
)

$full = Join-Path $PSScriptRoot $Path
$text = Get-Content -Raw -Path $full
$text | Out-File -FilePath $full -Encoding utf8
Write-Host "Re-saved $full as UTF-8 (with BOM)"

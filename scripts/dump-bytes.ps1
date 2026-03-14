param(
    [string]$Path = "..\public\zh\daily-commentary.html",
    [int]$Count = 32
)
$full = Join-Path $PSScriptRoot $Path
$bytes = [System.IO.File]::ReadAllBytes($full)
Write-Host "File: $full"
for ($i=0; $i -lt [Math]::Min($Count, $bytes.Length); $i++) {
    Write-Host -NoNewline ("{0:X2} " -f $bytes[$i])
}
Write-Host

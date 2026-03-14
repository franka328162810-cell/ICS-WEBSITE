$path = Join-Path $PSScriptRoot 'generate-daily-commentary.ps1'
$bytes = [System.IO.File]::ReadAllBytes($path)
for ($i=0; $i -lt 4; $i++) {
    Write-Host ('{0:X2}' -f $bytes[$i]) -NoNewline
    Write-Host ' '
}

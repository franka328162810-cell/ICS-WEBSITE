param([string]$file='publish-research-v4-seo.ps1')
$path = Join-Path $PSScriptRoot $file
$bytes = [System.IO.File]::ReadAllBytes($path)
for ($i=0; $i -lt $bytes.Length; $i++) {
    if ($bytes[$i] -ge 128) {
        Write-Host "Non-ASCII byte $($bytes[$i]) at index $i"
        break
    }
}
Write-Host 'Done'

param([string]$file='publish-research-v4-seo.ps1',[int]$line=123)
$path = Join-Path $PSScriptRoot $file
$lines = Get-Content -Path $path -Encoding UTF8
if ($line -le $lines.Count) {
    $text = $lines[$line-1]
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    Write-Host "Line $line bytes: $($bytes -join ', ')"
    Write-Host "Text: $text"
} else { Write-Host 'Line out of range' }

$files = @(
  'scripts/generate-daily-commentary.ps1',
  'templates/daily-commentary-zh-template.html',
  'templates/daily-commentary-en-template.html'
)

foreach ($f in $files) {
  $path = Join-Path $PSScriptRoot "..\$f"
  Write-Host "Re-saving $path as UTF8..."
  $text = Get-Content -Raw -Path $path -Encoding Default
  Set-Content -Path $path -Value $text -Encoding UTF8
}

param([string]$file='publish-research-v4-seo.ps1',[int]$linesCount=134)
$path = Join-Path $PSScriptRoot $file
$lines = Get-Content -Path $path -Encoding UTF8
$content = ($lines[0..($linesCount-1)] -join "`n")
$errors = [ref]@()
[System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, $errors) | Out-Null
if ($errors.Value.Count -gt 0) { foreach ($e in $errors.Value) { Write-Host $e.ToString() } } else { Write-Host 'PREFIX_PARSE_OK' }

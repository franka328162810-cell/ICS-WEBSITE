param([string]$file)
$path = Join-Path $PSScriptRoot $file
$content = Get-Content -Raw -Path $path
$errors = [ref]@()
[System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, $errors) | Out-Null
if ($errors.Value.Count -gt 0) {
    foreach ($e in $errors.Value) {
        Write-Host "Message: $($e.Message)"
        if ($e.Extent) {
            Write-Host "Start: Line $($e.Extent.StartLineNumber) Col $($e.Extent.StartColumnNumber)"
            Write-Host "End:   Line $($e.Extent.EndLineNumber) Col $($e.Extent.EndColumnNumber)"
            Write-Host "Text:  $($e.Extent.Text)"
        }
    }
} else { Write-Host 'PARSE_OK' }

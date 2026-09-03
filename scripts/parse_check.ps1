$files = @('seo_common.ps1','publish-daily-v4-seo.ps1','publish-research-v4-seo.ps1')
foreach ($f in $files) {
    $path = Join-Path $PSScriptRoot $f
    Write-Host "Checking: $f"
    $content = Get-Content -Raw -Path $path
    $errors = [ref]@()
    [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, $errors) | Out-Null
    if ($errors.Value.Count -gt 0) {
        foreach ($e in $errors.Value) {
            Write-Host $e.ToString()
        }
    } else {
        Write-Host "$f PARSE_OK"
    }
}

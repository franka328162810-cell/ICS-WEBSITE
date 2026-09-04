Param()
$roots = @('public','templates')
$updated = @()
foreach ($root in $roots) {
    if (-not (Test-Path $root)) { continue }
    Get-ChildItem -Path $root -Recurse -Include *.html,*.js -File | ForEach-Object {
        $path = $_.FullName
        try { $text = Get-Content -Raw -LiteralPath $path -Encoding UTF8 } catch { $text = Get-Content -Raw -LiteralPath $path -Encoding Default }
        $orig = $text
        # Simple, robust replacements to avoid complex regex parsing issues
        $text = $text -replace 'href="/compass/"','href="#"'
        $text = $text -replace "href='/compass/'","href='#'"
        $text = $text -replace '/compass/','#'
        # Neutralize compass CTA class names so styles/JS won't target them
        $text = $text -replace 'compass-cta','compass-cta-removed'
        $text = $text -replace 'compass-cta-icon','compass-cta-icon-removed'
        $text = $text -replace 'compass-cta-btn','compass-cta-btn-removed'
        $text = $text -replace 'Launch ICS Compass',''
        $text = $text -replace 'Launch Compass',''
        if ($text -ne $orig) {
            Set-Content -LiteralPath $path -Value $text -Encoding UTF8
            $updated += $path
            Write-Host "Updated: $path"
        }
    }
}
Write-Host "Total updated files: $($updated.Count)"

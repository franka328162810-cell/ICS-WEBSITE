Param()
$roots = @('public','templates')
$updated = @()
foreach ($root in $roots) {
    if (-not (Test-Path $root)) { continue }
    Get-ChildItem -Path $root -Recurse -Include *.html,*.js -File | ForEach-Object {
        $path = $_.FullName
        try { $text = Get-Content -Raw -LiteralPath $path -Encoding UTF8 } catch { $text = Get-Content -Raw -LiteralPath $path -Encoding Default }
        $orig = $text
        $text = [regex]::Replace($text, '<li>\s*<a\s+href=["\']?/compass/["\'][^>]*>.*?<\/a>\s*<\/li>', '', 'Singleline,IgnoreCase')
        $text = [regex]::Replace($text, '\.compass-cta\s*\{[\s\S]*?\}\s*', '', 'Singleline,IgnoreCase')
        $text = [regex]::Replace($text, '<div[^>]*class=["\'][^"\']*compass-cta[^"\']*["\'][^>]*>[\s\S]*?<\/div>\s*', '', 'Singleline,IgnoreCase')
        $text = $text -replace 'href="/compass/"','href="#"'
        $text = $text -replace "href='/compass/'","href='#'"
        $text = [regex]::Replace($text, '[\"\']compass[\"\']\s*,\s*', '', 'IgnoreCase')
        if ($text -ne $orig) {
            Set-Content -LiteralPath $path -Value $text -Encoding UTF8
            $updated += $path
            Write-Host "Updated: $path"
        }
    }
}
Write-Host "Total updated files: $($updated.Count)"

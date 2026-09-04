$roots = @("public", "templates")
$patterns = @{
    'nav_li' = '(?s)\s*<li>\s*<a\s+href=["\']?/compass/["\'][^>]*>.*?<\/a>\s*<\/li>\s*'
    'href' = 'href=["\']?/compass/["\']'
    'css_block' = '(?s)\.compass-cta\s*\{.*?\}\s*'
    'html_cta' = '(?s)<div[^>]*class=["\'][^"\']*compass-cta[^"\']*["\'][^>]*>.*?<\/div>\s*'
    'js_keyword' = '["\']compass["\']\s*,\s*'
}
$updated = @()
foreach ($root in $roots) {
    if (-not (Test-Path $root)) { continue }
    Get-ChildItem -Path $root -Recurse -Include *.html,*.js -File | ForEach-Object {
        $path = $_.FullName
        try {
            $text = Get-Content -Raw -Encoding UTF8 $path
        } catch {
            $text = Get-Content -Raw -Encoding Default $path
        }
        $orig = $text
        $text = [regex]::Replace($text, $patterns['nav_li'], '', 'Singleline,IgnoreCase')
        $text = [regex]::Replace($text, $patterns['css_block'], '', 'Singleline,IgnoreCase')
        $text = [regex]::Replace($text, $patterns['html_cta'], '', 'Singleline,IgnoreCase')
        $text = [regex]::Replace($text, $patterns['href'], 'href="#"', 'IgnoreCase')
        $text = [regex]::Replace($text, $patterns['js_keyword'], '', 'IgnoreCase')
        if ($text -ne $orig) {
            Set-Content -LiteralPath $path -Value $text -Encoding UTF8
            $updated += $path
            Write-Host "Updated: $path"
        }
    }
}
Write-Host "Total updated files: $($updated.Count)"
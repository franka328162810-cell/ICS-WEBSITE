# Neutralize compass- prefixes and compass ids in HTML/JS/CSS files
$changed = @()
Get-ChildItem -Recurse -Include *.html,*.js,*.css -File | ForEach-Object {
    $p = $_.FullName
    try {
        $t = Get-Content -Raw -Encoding UTF8 -ErrorAction Stop -Path $p
    } catch {
        $t = Get-Content -Raw -Encoding Default -Path $p
    }
    $nt = $t

    # Basic prefix and id replacements
    $nt = $nt -replace 'compass-','compass-removed-'
    $nt = $nt -replace 'id="compass','id="compass-removed'
    $nt = $nt -replace "id='compass","id='compass-removed'"

    # Dot and hash selectors (e.g. .compass, #compass)
    $nt = [regex]::Replace($nt, '\.compass\b', '.compass-removed', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $nt = [regex]::Replace($nt, '\#compass\b', '#compass-removed', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    # CSS attribute selectors like [class*="compass"] or [class~="compass"]
    $nt = $nt -replace 'class\*=\"compass','class*=\"compass-removed'
    $nt = $nt -replace "class*=\'compass","class*=\'compass-removed'"
    $nt = $nt -replace 'class~=\"compass','class~=\"compass-removed'
    $nt = $nt -replace "class~=\'compass","class~=\'compass-removed'"

    # Replace string constants and object keys: 'compass', "compass", "compass":, 'compass':
    $nt = $nt -replace '"compass"','"compass-removed"'
    $nt = $nt -replace "'compass'","'compass-removed'"
    $nt = [regex]::Replace($nt, '"compass"\s*:', '"compass-removed":', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $nt = [regex]::Replace($nt, "'compass'\s*:", "'compass-removed':", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    # Also neutralize selector prefixes used in JS/CSS like ".compass-" already handled by prefix replace; ensure standalone .compass followed by non-word handled
    $nt = [regex]::Replace($nt, '\.compass(?!-removed)', '.compass-removed', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    if ($t -ne $nt) {
        Set-Content -Encoding UTF8 -Value $nt -Path $p
        $changed += $p
        Write-Host "Neutralized: $p"
    }
}
Write-Host "Total neutralized files: $($changed.Count)"
if ($changed.Count -gt 0) { $changed | Out-File -Encoding UTF8 compass_neutralized_files.txt }

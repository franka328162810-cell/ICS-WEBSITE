# Auto-fix missing canonical/og based on seo_audit output
param()
Set-Location $PSScriptRoot
. .\seo_common.ps1
# Run seo_audit and capture output
$raw = & powershell -NoProfile -File .\seo_audit.ps1 2>&1
# Extract lines under MISSING_CANONICAL= and MISSING_OG=
$missing = @()
$mode = ''
foreach ($line in $raw) {
    if ($line -match '^MISSING_CANONICAL=') { $mode = 'canonical'; continue }
    if ($line -match '^MISSING_OG=') { $mode = 'og'; continue }
    if ($line -match '^$') { continue }
    if ($line -match '^C:\\Users\\') {
        if ($mode -ne '') { $missing += $line }
    }
}
if ($missing.Count -eq 0) { Write-Host 'No missing canonical/og files found.'; exit 0 }

$modified = @()
foreach ($full in $missing) {
    $path = $full
    if (-not (Test-Path $path)) { Write-Host "Skipping missing path: $path"; continue }
    $html = Get-Content -Raw -Path $path -Encoding UTF8
    # extract title
    $title = ''
    if ($html -match '<title>(.*?)</title>') { $title = $matches[1].Trim() }
    # extract meta description (skip complex extraction; leave empty if not found)
    $desc = ''
    # build url from path: remove workspace prefix and public/ prefix
    $rel = $path -replace [regex]::Escape((Get-Location).Path + '\\'),' '
    $rel = $path.Substring((Get-Location).Path.Length + 1)
    $relPos = $rel.IndexOf('public\\')
    if ($relPos -ge 0) { $rel = $rel.Substring($relPos + 7) }
    $url = 'https://ics-studies.org/' + ($rel -replace '\\','/')
    # guess locale
    $locale = if ($url -match '/zh/') { 'zh' } else { 'en' }
    # Use ASCII site name to avoid encoding issues in PS parsing
    $siteName = 'Interstellar Civilization Studies'
    $author = 'ICS Research Institute'
    # Inject SEO block
    $newHtml = Inject-SeoBlock -Html $html -Title $title -Description $desc -Url $url -Locale $locale -AlternateLocale (if ($locale -eq 'zh') { 'en' } else { 'zh' }) -AlternateUrl $url -SiteName $siteName -Author $author -PublishedTime ''
    if ($newHtml -ne $null) {
        Set-Content -Path $path -Value $newHtml -Encoding UTF8 -NoNewline
        $modified += $path
        Write-Host "Patched: $path"
    }
}
# Re-run audit for validation
Write-Host "Modified $($modified.Count) files. Re-running seo_audit..."
& powershell -NoProfile -File .\seo_audit.ps1

Write-Host "Done."



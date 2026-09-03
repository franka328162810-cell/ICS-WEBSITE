# Robust auto-fix for missing canonical/og
Set-Location $PSScriptRoot
. .\seo_common.ps1
$raw = & powershell -NoProfile -File .\seo_audit.ps1 2>&1 | Out-String
$lines = $raw -split "`n"
function Collect-Block($header) {
    $start = ($lines | Select-String -Pattern "^$header" | Select-Object -First 1).LineNumber
    if (-not $start) { return @() }
    $result = @()
    for ($i = $start; $i -lt $lines.Length; $i++) {
        $ln = $lines[$i].Trim()
        if ($ln -eq '') { continue }
        # stop if next header encountered
        if ($ln -match '^MISSING_') { break }
        if ($ln -match '^[A-Za-z]:\\') { $result += $ln }
    }
    return $result
}
$missingCanonical = Collect-Block 'MISSING_CANONICAL='
$missingOg = Collect-Block 'MISSING_OG='
$targets = ($missingCanonical + $missingOg) | Select-Object -Unique
if ($targets.Count -eq 0) { Write-Host 'No missing canonical/og files found.'; exit 0 }

$modified = @()
foreach ($path in $targets) {
    if (-not (Test-Path $path)) { Write-Host "Skipping not found: $path"; continue }
    $html = Get-Content -Raw -Path $path -Encoding UTF8
    $title = ''
    if ($html -match '<title>(.*?)</title>') { $title = $matches[1].Trim() }
    $desc = ''
    $rel = $path.Substring((Get-Location).Path.Length + 1)
    $relPos = $rel.IndexOf('public\\')
    if ($relPos -ge 0) { $rel = $rel.Substring($relPos + 7) }
    $url = 'https://ics-studies.org/' + ($rel -replace '\\','/')
    $locale = if ($url -match '/zh/') { 'zh' } else { 'en' }
    $siteName = 'Interstellar Civilization Studies'
    $author = 'ICS Research Institute'
    $newHtml = Inject-SeoBlock -Html $html -Title $title -Description $desc -Url $url -Locale $locale -AlternateLocale (if ($locale -eq 'zh') { 'en' } else { 'zh' }) -AlternateUrl $url -SiteName $siteName -Author $author -PublishedTime ''
    if ($newHtml -ne $null) {
        Set-Content -Path $path -Value $newHtml -Encoding UTF8 -NoNewline
        $modified += $path
        Write-Host "Patched: $path"
    }
}
Write-Host "Patched $($modified.Count) files; re-running seo_audit..."
& powershell -NoProfile -File .\seo_audit.ps1
Write-Host 'Done.'

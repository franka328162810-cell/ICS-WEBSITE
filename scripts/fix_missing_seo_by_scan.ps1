Set-Location $PSScriptRoot
. .\seo_common.ps1
$public = Join-Path (Get-Location).Path '..\public'
$files = Get-ChildItem -Path $public -Recurse -Filter *.html | Select-Object -ExpandProperty FullName
$targets = @()
foreach ($f in $files) {
    $html = Get-Content -Raw -Path $f -Encoding UTF8
    $lower = $html.ToLower()
    $hasCanonical = $lower.Contains('rel="canonical') -or $lower.Contains("rel='canonical") -or $lower.Contains('rel=canonical')
    $hasOg = $lower.Contains('property="og:') -or $lower.Contains("property='og:") -or $lower.Contains('property=og:')
    if (-not $hasCanonical -or -not $hasOg) { $targets += $f }
}
Write-Host "Found $($targets.Count) target files to patch."
$modified = @()
foreach ($path in $targets) {
    Write-Host "Patching: $path"
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
    $altLocale = if ($locale -eq 'zh') { 'en' } else { 'zh' }
    try {
        $newHtml = Inject-SeoBlock -Html $html -Title $title -Description $desc -Url $url -Locale $locale -AlternateLocale $altLocale -AlternateUrl $url -SiteName $siteName -Author $author -PublishedTime ''
        if ($newHtml -ne $null) {
            Set-Content -Path $path -Value $newHtml -Encoding UTF8 -NoNewline
            $modified += $path
        }
    } catch {
        Write-Host "Skipped (inject failed): $path -> $($_.Exception.Message)"
        continue
    }
}
Write-Host "Patched $($modified.Count) files." 
& powershell -NoProfile -File .\seo_audit.ps1

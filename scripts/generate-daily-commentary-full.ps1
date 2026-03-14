param(
    [string]$ContentJson = "scripts/daily-commentary-20260314-full.json"
)

# Load content data
if (!(Test-Path $ContentJson)) {
    Write-Error "Content file not found: $ContentJson"
    exit 1
}
$content = Get-Content -Raw -Path $ContentJson -Encoding UTF8 | ConvertFrom-Json

# Shared values
$readingTimeZh = '约15分钟'
$readingTimeEn = 'approx 15 minutes'
$filename = 'daily-commentary'
$filenameEn = $content.meta.filenameEn
$filenameZh = $content.meta.filenameZh

# Build Chinese main content
$zhMainSections = @()

# Add intro
$zhMainSections += @"
<section class="article-intro">
  <h2 class="zh-section-title">$($content.zh.headline)</h2>
  <h3 class="zh-section-subtitle">$($content.zh.subheadline)</h3>
  <div class="news-source">
    <span>$($content.zh.source)</span>
    <span class="source-divider">|</span>
    <span>$($content.zh.sourceTime)</span>
  </div>
  <div class="content-card intro-text">
    $(($content.zh.intro -split '\n\n' | ForEach-Object { "<p>$_</p>" }) -join "`n    ")
  </div>
</section>
"@

# Add each section
foreach ($section in $content.zh.sections) {
    if ($section.isTable) {
        # Build table
        $tableRows = $section.content | ForEach-Object {
            "<tr><td>$($_.metric)</td><td>$($_.value)</td><td>$($_.interpretation)</td></tr>"
        }
        $tableHeaders = $section.tableHeaders -join '</th><th>'
        $zhMainSections += @"
<section class="article-section">
  <h3 class="section-heading">$($section.title)</h3>
  <div class="content-card">
    <table class="ics-metrics-table">
      <thead>
        <tr>
          <th>$tableHeaders</th>
        </tr>
      </thead>
      <tbody>
        $($tableRows -join "`n        ")
      </tbody>
    </table>
  </div>
</section>
"@
    } else {
        # Regular text section
        $paragraphs = $section.content -split '\n\n' | ForEach-Object { 
            "<p>$_</p>"
        }
        $zhMainSections += @"
<section class="article-section">
  <h3 class="section-heading">$($section.title)</h3>
  <div class="content-card">
    $($paragraphs -join "`n    ")
  </div>
</section>
"@
    }
}

# Add footer
if ($content.zh.footer) {
    $zhMainSections += @"
<section class="article-footer">
  <div class="content-card footer-note">
    <p>$($content.zh.footer)</p>
  </div>
</section>
"@
}

$zhMain = $zhMainSections -join "`n`n"

# Generate Chinese page
$zhTemplate = Get-Content -Raw -Path "templates/daily-commentary-zh-template.html" -Encoding UTF8
$related = ""
$zhOut = $zhTemplate.Replace('{{HEADLINE}}',$content.zh.headline).Replace('{{SHORT_SUMMARY}}',$content.zh.subheadline).Replace('{{DATE}}',$content.zh.date).Replace('{{READING_TIME}}',$readingTimeZh).Replace('{{FILENAME}}',$filename).Replace('{{FILENAME_EN}}',$filenameEn).Replace('{{MAIN_CONTENT}}',$zhMain).Replace('{{RELATED_ARTICLES}}',$related)

# Use .NET to write UTF-8 without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD\public\zh\$filenameZh.html", $zhOut, $utf8NoBom)
[System.IO.File]::WriteAllText("$PWD\public\zh\daily-commentary.html", $zhOut, $utf8NoBom)

Write-Host "Generated Chinese daily commentary with full content." -ForegroundColor Green
Write-Host "Sections: $($content.zh.sections.Count)" -ForegroundColor Cyan

# ============ ENGLISH PAGE GENERATION ============

# Build English main content
$enMainSections = @()

# Add intro
$enMainSections += @"
<section class="article-intro">
  <h2 class="en-section-title">$($content.en.headline)</h2>
  <h3 class="en-section-subtitle">$($content.en.subheadline)</h3>
  <div class="news-source">
    <span>$($content.en.source)</span>
    <span class="source-divider">|</span>
    <span>$($content.en.sourceTime)</span>
  </div>
  <div class="content-card intro-text">
    $(($content.en.intro -split '\n\n' | ForEach-Object { "<p>$_</p>" }) -join "`n    ")
  </div>
</section>
"@

# Add each section
foreach ($section in $content.en.sections) {
    if ($section.isTable) {
        # Build table
        $tableRows = $section.content | ForEach-Object {
            "<tr><td>$($_.metric)</td><td>$($_.value)</td><td>$($_.interpretation)</td></tr>"
        }
        $tableHeaders = $section.tableHeaders -join '</th><th>'
        $enMainSections += @"
<section class="article-section">
  <h3 class="section-heading">$($section.title)</h3>
  <div class="content-card">
    <table class="ics-metrics-table">
      <thead>
        <tr>
          <th>$tableHeaders</th>
        </tr>
      </thead>
      <tbody>
        $($tableRows -join "`n        ")
      </tbody>
    </table>
  </div>
</section>
"@
    } else {
        # Regular text section
        $paragraphs = $section.content -split '\n\n' | ForEach-Object { 
            "<p>$_</p>"
        }
        $enMainSections += @"
<section class="article-section">
  <h3 class="section-heading">$($section.title)</h3>
  <div class="content-card">
    $($paragraphs -join "`n    ")
  </div>
</section>
"@
    }
}

# Add footer
if ($content.en.footer) {
    $enMainSections += @"
<section class="article-footer">
  <div class="content-card footer-note">
    <p>$($content.en.footer)</p>
  </div>
</section>
"@
}

$enMain = $enMainSections -join "`n`n"

# Generate English page
$enTemplate = Get-Content -Raw -Path "templates/daily-commentary-en-template.html" -Encoding UTF8
$enOut = $enTemplate.Replace('{{HEADLINE}}',$content.en.headline).Replace('{{SHORT_SUMMARY}}',$content.en.subheadline).Replace('{{DATE}}',$content.en.date).Replace('{{READING_TIME}}',$readingTimeEn).Replace('{{FILENAME}}',$filename).Replace('{{FILENAME_EN}}',$filenameEn).Replace('{{FILENAME_ZH}}',$filenameZh).Replace('{{MAIN_CONTENT}}',$enMain).Replace('{{RELATED_ARTICLES}}',$related)

# Use .NET to write UTF-8 without BOM
[System.IO.File]::WriteAllText("$PWD\public\en\daily-commentary.html", $enOut, $utf8NoBom)

Write-Host "Generated English daily commentary with full content." -ForegroundColor Green
Write-Host "Sections: $($content.en.sections.Count)" -ForegroundColor Cyan

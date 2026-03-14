param(
    [string]$ContentJson = "scripts/daily-commentary-20260314.json"
)

# Load content data
if (!(Test-Path $ContentJson)) {
    Write-Error "Content file not found: $ContentJson"
    exit 1
}
$content = Get-Content -Raw -Path $ContentJson -Encoding UTF8 | ConvertFrom-Json

# Shared values
$readingTimeZh = '约6分钟'
$readingTimeEn = 'approx 6 minutes'
$filename = 'daily-commentary'
$filenameEn = $content.meta.filenameEn
$filenameZh = $content.meta.filenameZh

# Chinese page - use actual content from JSON
$zhTemplate = Get-Content -Raw -Path "templates/daily-commentary-zh-template.html" -Encoding UTF8
$zhMain = @"
<section>
  <h2 class="zh-section-title">$($content.zh.headline)</h2>
  <div class="news-source">
    <span>$($content.zh.source)</span>
    <span class="source-divider">|</span>
    <span>$($content.zh.sourceTime)</span>
  </div>
  <div class="content-card">
    <p>$($content.zh.summary)</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title">$($content.zh.sectionTitles.newViews)</h2>
  <div class="content-card">
    <p>$($content.zh.newThreeViews)</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title">$($content.zh.sectionTitles.normative)</h2>
  <div class="content-card">
    <p>$($content.zh.normative)</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title">$($content.zh.sectionTitles.impact)</h2>
  <div class="content-card">
    <p>$($content.zh.longTermImpact)</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title">$($content.zh.sectionTitles.reflection)</h2>
  <div class="content-card">
    <p>$($content.zh.reflectionQ1)</p>
    <p>$($content.zh.reflectionQ2)</p>
  </div>
</section>
"@

$related = ""
$zhOut = $zhTemplate.Replace('{{HEADLINE}}',$content.zh.headline).Replace('{{SHORT_SUMMARY}}',$content.zh.summary).Replace('{{DATE}}',$content.zh.date).Replace('{{READING_TIME}}',$readingTimeZh).Replace('{{FILENAME}}',$filename).Replace('{{FILENAME_EN}}',$filenameEn).Replace('{{MAIN_CONTENT}}',$zhMain).Replace('{{RELATED_ARTICLES}}',$related)

# Use .NET to write UTF-8 without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD\public\zh\$filenameZh.html", $zhOut, $utf8NoBom)
[System.IO.File]::WriteAllText("$PWD\public\zh\daily-commentary.html", $zhOut, $utf8NoBom)

# English page - use actual content from JSON
$enTemplate = Get-Content -Raw -Path "templates/daily-commentary-en-template.html" -Encoding UTF8
$enMain = @"
<section>
  <h2 class="en-section-title">$($content.en.headline)</h2>
  <div class="news-source">
    <span>$($content.en.source)</span>
    <span class="source-divider">|</span>
    <span>$($content.en.sourceTime)</span>
  </div>
  <div class="content-card">
    <p>$($content.en.summary)</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">$($content.en.sectionTitles.newViews)</h2>
  <div class="content-card">
    <p>$($content.en.newThreeViews)</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">$($content.en.sectionTitles.normative)</h2>
  <div class="content-card">
    <p>$($content.en.normative)</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">$($content.en.sectionTitles.impact)</h2>
  <div class="content-card">
    <p>$($content.en.longTermImpact)</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">$($content.en.sectionTitles.reflection)</h2>
  <div class="content-card">
    <p><strong>Q1:</strong> $($content.en.reflectionQ1)</p>
    <p><strong>Q2:</strong> $($content.en.reflectionQ2)</p>
  </div>
</section>
"@

$enOut = $enTemplate.Replace('{{HEADLINE}}',$content.en.headline).Replace('{{SHORT_SUMMARY}}',$content.en.summary).Replace('{{DATE}}',$content.en.date).Replace('{{READING_TIME}}',$readingTimeEn).Replace('{{FILENAME}}',$filename).Replace('{{FILENAME_EN}}',$filenameEn).Replace('{{FILENAME_ZH}}',$filenameZh).Replace('{{MAIN_CONTENT}}',$enMain).Replace('{{RELATED_ARTICLES}}',$related)

# Use .NET to write UTF-8 without BOM
[System.IO.File]::WriteAllText("$PWD\public\en\daily-commentary.html", $enOut, $utf8NoBom)

Write-Host "Generated zh and en daily commentary pages from JSON content with UTF-8 (no BOM)." -ForegroundColor Green

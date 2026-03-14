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
$filenameEn = 'daily-commentary'
$filenameZh = '每日热点评论'

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
  <h2 class="zh-section-title"><span class="section-icon">🔍</span> 三个新视角</h2>
  <div class="content-card">
    <p>$($content.zh.newThreeViews)</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">⚖️</span> ICS框架规范性判断</h2>
  <div class="content-card">
    <p>$($content.zh.normative)</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">🔮</span> 长期影响评估</h2>
  <div class="content-card">
    <p>$($content.zh.longTermImpact)</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">💭</span> 反思问题</h2>
  <div class="content-card">
    <p><strong>问题1：</strong>$($content.zh.reflectionQ1)</p>
    <p><strong>问题2：</strong>$($content.zh.reflectionQ2)</p>
  </div>
</section>
"@

$related = ""
$zhOut = $zhTemplate.Replace('{{HEADLINE}}',$content.zh.headline).Replace('{{SHORT_SUMMARY}}',$content.zh.summary).Replace('{{DATE}}',$content.zh.date).Replace('{{READING_TIME}}',$readingTimeZh).Replace('{{FILENAME}}',$filename).Replace('{{FILENAME_EN}}',$filenameEn).Replace('{{MAIN_CONTENT}}',$zhMain).Replace('{{RELATED_ARTICLES}}',$related)
$zhOut | Set-Content -Path "public/zh/$filenameZh.html" -Encoding UTF8
$zhOut | Set-Content -Path "public/zh/daily-commentary.html" -Encoding UTF8

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
  <h2 class="en-section-title"><span class="section-icon">🔍</span> Three New Perspectives</h2>
  <div class="content-card">
    <p>$($content.en.newThreeViews)</p>
  </div>
</section>

<section>
  <h2 class="en-section-title"><span class="section-icon">⚖️</span> ICS Normative Assessment</h2>
  <div class="content-card">
    <p>$($content.en.normative)</p>
  </div>
</section>

<section>
  <h2 class="en-section-title"><span class="section-icon">🔮</span> Long-term Impact</h2>
  <div class="content-card">
    <p>$($content.en.longTermImpact)</p>
  </div>
</section>

<section>
  <h2 class="en-section-title"><span class="section-icon">💭</span> Reflection Questions</h2>
  <div class="content-card">
    <p><strong>Q1:</strong> $($content.en.reflectionQ1)</p>
    <p><strong>Q2:</strong> $($content.en.reflectionQ2)</p>
  </div>
</section>
"@

$enOut = $enTemplate.Replace('{{HEADLINE}}',$content.en.headline).Replace('{{SHORT_SUMMARY}}',$content.en.summary).Replace('{{DATE}}',$content.en.date).Replace('{{READING_TIME}}',$readingTimeEn).Replace('{{FILENAME}}',$filename).Replace('{{FILENAME_EN}}',$filenameEn).Replace('{{FILENAME_ZH}}',$filenameZh).Replace('{{MAIN_CONTENT}}',$enMain).Replace('{{RELATED_ARTICLES}}',$related)
$enOut | Set-Content -Path "public/en/daily-commentary.html" -Encoding UTF8

Write-Host "Generated zh and en daily commentary pages from JSON content." -ForegroundColor Green

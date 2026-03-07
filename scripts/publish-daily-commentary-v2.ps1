param(
    [Parameter(Mandatory = $true)]
    [string]$ContentFile,

    [switch]$Deploy
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Replace-ByPattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$NewValue,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $rx = [System.Text.RegularExpressions.Regex]::new(
        $Pattern,
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $match = $rx.Match($Text)
    if (-not $match.Success) {
        throw "未匹配到段落：$Label"
    }

    $old = $match.Groups['old']
    return $Text.Substring(0, $old.Index) + $NewValue + $Text.Substring($old.Index + $old.Length)
}

function Join-Tags {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Tags
    )

    return ($Tags | ForEach-Object { "                        <span class=""tag-item"">$($_)</span>" }) -join "`r`n"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$contentPath = if ([System.IO.Path]::IsPathRooted($ContentFile)) { $ContentFile } else { Join-Path $repoRoot $ContentFile }

if (-not (Test-Path -LiteralPath $contentPath)) {
    throw "内容文件不存在：$contentPath"
}

$data = Get-Content -LiteralPath $contentPath -Raw -Encoding UTF8 | ConvertFrom-Json

$enFile = Join-Path $repoRoot 'public/en/daily-commentary.html'
$zhFile = Join-Path $repoRoot 'public/zh/每日热点评论.html'

$en = Get-Content -LiteralPath $enFile -Raw -Encoding UTF8
$zh = Get-Content -LiteralPath $zhFile -Raw -Encoding UTF8

# ---------------- EN ----------------
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><span class="meta-icon">📅</span>\s*<span>)(?<old>.*?)(?<post></span>)' -NewValue $data.en.date -Label 'EN date'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><span class="category-badge">)(?<old>.*?)(?<post></span>)' -NewValue $data.en.category -Label 'EN category'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><h3 class="news-title">)(?<old>.*?)(?<post></h3>)' -NewValue $data.en.headline -Label 'EN headline'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><div class="news-source">\s*<span>)(?<old>.*?)(?<post></span>)' -NewValue $data.en.source -Label 'EN source'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><span class="source-divider">\|</span>\s*<span>)(?<old>.*?)(?<post></span>)' -NewValue $data.en.sourceTime -Label 'EN source time'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre>News Summary\s*</h2>\s*<div class="content-card">\s*<p>)(?<old>.*?)(?<post></p>)' -NewValue $data.en.summary -Label 'EN summary'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><h3 class="en-subsection-title">From the New Three Views</h3>\s*<p>)(?<old>.*?)(?<post></p>)' -NewValue $data.en.newThreeViews -Label 'EN newThreeViews'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><h3 class="en-subsection-title">Normative Considerations</h3>\s*<p>)(?<old>.*?)(?<post></p>)' -NewValue $data.en.normative -Label 'EN normative'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><h3 class="en-subsection-title">Long-term Impact</h3>\s*<p>)(?<old>.*?)(?<post></p>)' -NewValue $data.en.longTermImpact -Label 'EN longTermImpact'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><div class="question-item" data-number="1\\.">)(?<old>.*?)(?<post></div>)' -NewValue $data.en.reflectionQ1 -Label 'EN reflectionQ1'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><div class="question-item" data-number="2\\.">)(?<old>.*?)(?<post></div>)' -NewValue $data.en.reflectionQ2 -Label 'EN reflectionQ2'
$en = Replace-ByPattern -Text $en -Pattern '(?<pre><div class="tags-list">\s*)(?<old>.*?)(?<post>\s*</div>\s*</div>\s*</section>)' -NewValue (Join-Tags -Tags $data.en.tags) -Label 'EN tags'

# ---------------- ZH ----------------
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><span class="meta-icon">📅</span>\s*<span>)(?<old>.*?)(?<post></span>)' -NewValue $data.zh.date -Label 'ZH date'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><span class="category-badge">)(?<old>.*?)(?<post></span>)' -NewValue $data.zh.category -Label 'ZH category'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><h3 class="news-title">)(?<old>.*?)(?<post></h3>)' -NewValue $data.zh.headline -Label 'ZH headline'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><div class="news-source">\s*<span>)(?<old>.*?)(?<post></span>)' -NewValue $data.zh.source -Label 'ZH source'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><span class="source-divider">\|</span>\s*<span>)(?<old>.*?)(?<post></span>)' -NewValue $data.zh.sourceTime -Label 'ZH source time'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre>新闻摘要\s*</h2>\s*<div class="content-card">\s*<p>)(?<old>.*?)(?<post></p>)' -NewValue $data.zh.summary -Label 'ZH summary'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><h3 class="zh-subsection-title">从新三观看</h3>\s*<p>)(?<old>.*?)(?<post></p>)' -NewValue $data.zh.newThreeViews -Label 'ZH newThreeViews'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><h3 class="zh-subsection-title">规范性思考</h3>\s*<p>)(?<old>.*?)(?<post></p>)' -NewValue $data.zh.normative -Label 'ZH normative'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><h3 class="zh-subsection-title">长期影响</h3>\s*<p>)(?<old>.*?)(?<post></p>)' -NewValue $data.zh.longTermImpact -Label 'ZH longTermImpact'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><div class="question-item" data-number="1\\.">)(?<old>.*?)(?<post></div>)' -NewValue $data.zh.reflectionQ1 -Label 'ZH reflectionQ1'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><div class="question-item" data-number="2\\.">)(?<old>.*?)(?<post></div>)' -NewValue $data.zh.reflectionQ2 -Label 'ZH reflectionQ2'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<pre><div class="tags-list">\s*)(?<old>.*?)(?<post>\s*</div>\s*</div>\s*</section>)' -NewValue (Join-Tags -Tags $data.zh.tags) -Label 'ZH tags'

Set-Content -LiteralPath $enFile -Value $en -Encoding UTF8
Set-Content -LiteralPath $zhFile -Value $zh -Encoding UTF8

# produce ascii alias for Chinese page
$zhAlias = Join-Path $repoRoot 'public/zh/daily-commentary.html'
$aliasContent = "<!DOCTYPE html><html lang='zh-CN'><head><meta charset='UTF-8'><meta http-equiv='refresh' content='0; url=每日热点评论.html'><link rel='canonical' href='每日热点评论.html'></head><body></body></html>"
Set-Content -LiteralPath $zhAlias -Value $aliasContent -Encoding UTF8

Write-Host "已更新：public/en/daily-commentary.html"
Write-Host "已更新：public/zh/每日热点评论.html"
Write-Host "已创建别名：public/zh/daily-commentary.html"

if ($Deploy) {
    $headline = "$($data.en.headline)".Trim()
    if ([string]::IsNullOrWhiteSpace($headline)) {
        $headline = 'daily commentary update'
    }

    & git -C $repoRoot add "public/en/daily-commentary.html" "public/zh/每日热点评论.html" "public/zh/daily-commentary.html"
    & git -C $repoRoot commit -m "publish: daily commentary - $headline"
    & git -C $repoRoot push

    Write-Host "Git push completed. Deployment platform will auto-publish."
}

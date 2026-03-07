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
        throw "Paragraph not found: $Label"
    }

    $old = $match.Groups['old']
    return $Text.Substring(0, $old.Index) + $NewValue + $Text.Substring($old.Index + $old.Length)
}

# encoding: UTF8
function Join-Tags {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Tags
    )

    # double-double-quotes escape to produce literal quotes in output
    return ($Tags | ForEach-Object { "                        <span class=""tag-item"">$($_)</span>" }) -join "`r`n"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$contentPath = if ([System.IO.Path]::IsPathRooted($ContentFile)) { $ContentFile } else { Join-Path $repoRoot $ContentFile }

if (-not (Test-Path -LiteralPath $contentPath)) {
    throw "Content file not found: $contentPath"
}

$data = Get-Content -LiteralPath $contentPath -Raw -Encoding UTF8 | ConvertFrom-Json

$enFile = Join-Path $repoRoot 'public/en/daily-commentary.html'
$zhFile = Join-Path $repoRoot 'public/zh/每日热点评论.html'

$en = Get-Content -LiteralPath $enFile -Raw -Encoding UTF8
$zh = Get-Content -LiteralPath $zhFile -Raw -Encoding UTF8

function NormalizeHtml {
    param([string]$html)
    # make sure <!DOCTYPE html> is the very first token
    $idx = $html.IndexOf('<!DOCTYPE')
    if ($idx -gt 0) {
        $html = $html.Substring($idx)
    }
    return $html
}


# ---------------- EN ----------------
$en = Replace-ByPattern -Text $en -Pattern '(?<=<span class="category-badge"[^>]*>)(?<old>.*?)(?=</span>)' -NewValue $data.en.category -Label 'EN category'
$en = Replace-ByPattern -Text $en -Pattern '(?<=<h3 class="news-title"[^>]*>)(?<old>.*?)(?=</h3>)' -NewValue $data.en.headline -Label 'EN headline'
# update meta published_time and JSON-LD datePublished
$en = Replace-ByPattern -Text $en -Pattern '(?<=<meta property="article:published_time" content=")[^"]*(?="\>)' -NewValue $data.en.date -Label 'EN meta date'
$en = Replace-ByPattern -Text $en -Pattern '(?<=\"datePublished\":\")[^"]*(?=\")' -NewValue $data.en.date -Label 'EN jsonld datePublished'
$en = Replace-ByPattern -Text $en -Pattern '(?<=<div class="news-source">\s*<span[^>]*>)(?<old>.*?)(?=</span>)' -NewValue $data.en.source -Label 'EN source'
$en = Replace-ByPattern -Text $en -Pattern '(?<=<span class="source-divider">\|</span>\s*<span[^>]*>)(?<old>.*?)(?=</span>)' -NewValue $data.en.sourceTime -Label 'EN source time'
$en = Replace-ByPattern -Text $en -Pattern '(?<=<p[^>]*data-field="summary"[^>]*>)(?<old>.*?)(?=</p>)' -NewValue $data.en.summary -Label 'EN summary'
$en = Replace-ByPattern -Text $en -Pattern '(?<=<p[^>]*data-field="newThreeViews"[^>]*>)(?<old>.*?)(?=</p>)' -NewValue $data.en.newThreeViews -Label 'EN newThreeViews'
$en = Replace-ByPattern -Text $en -Pattern '(?<=<p[^>]*data-field="normative"[^>]*>)(?<old>.*?)(?=</p>)' -NewValue $data.en.normative -Label 'EN normative'
$en = Replace-ByPattern -Text $en -Pattern '(?<=<p[^>]*data-field="longTermImpact"[^>]*>)(?<old>.*?)(?=</p>)' -NewValue $data.en.longTermImpact -Label 'EN longTermImpact'
$en = Replace-ByPattern -Text $en -Pattern '(?<=<div class="question-item"[^>]*data-number="1\."[^>]*>)(?<old>.*?)(?=</div>)' -NewValue $data.en.reflectionQ1 -Label 'EN reflectionQ1'
$en = Replace-ByPattern -Text $en -Pattern '(?<=<div class="question-item"[^>]*data-number="2\."[^>]*>)(?<old>.*?)(?=</div>)' -NewValue $data.en.reflectionQ2 -Label 'EN reflectionQ2'
$en = Replace-ByPattern -Text $en -Pattern '(?<=<div class="tags-list"[^>]*>\s*)(?<old>.*?)(?=\s*</div>\s*</div>\s*</section>)' -NewValue (Join-Tags -Tags $data.en.tags) -Label 'EN tags'

# ---------------- ZH ----------------
# visible date in new template
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<span data-field="date">)(?<old>.*?)(?=</span>)' -NewValue $data.zh.date -Label 'ZH date'
# update zh meta and jsonld
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<meta property="article:published_time" content=")[^"]*(?="\>)' -NewValue $data.zh.date -Label 'ZH meta date'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=\"datePublished\":\")[^"]*(?=\")' -NewValue $data.zh.date -Label 'ZH jsonld datePublished'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<span class="category-badge"[^>]*>)(?<old>.*?)(?=</span>)' -NewValue $data.zh.category -Label 'ZH category'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<h3 class="news-title"[^>]*>)(?<old>.*?)(?=</h3>)' -NewValue $data.zh.headline -Label 'ZH headline'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<div class="news-source">\s*<span[^>]*>)(?<old>.*?)(?=</span>)' -NewValue $data.zh.source -Label 'ZH source'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<span class="source-divider">\|</span>\s*<span[^>]*>)(?<old>.*?)(?=</span>)' -NewValue $data.zh.sourceTime -Label 'ZH source time'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=新闻摘要\s*</h2>\s*<div class="content-card">\s*<p>)(?<old>.*?)(?=</p>)' -NewValue $data.zh.summary -Label 'ZH summary'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<p[^>]*data-field="newThreeViews"[^>]*>)(?<old>.*?)(?=</p>)' -NewValue $data.zh.newThreeViews -Label 'ZH newThreeViews'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<p[^>]*data-field="normative"[^>]*>)(?<old>.*?)(?=</p>)' -NewValue $data.zh.normative -Label 'ZH normative'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<p[^>]*data-field="longTermImpact"[^>]*>)(?<old>.*?)(?=</p>)' -NewValue $data.zh.longTermImpact -Label 'ZH longTermImpact'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<div class="question-item"[^>]*data-number="1\."[^>]*>)(?<old>.*?)(?=</div>)' -NewValue $data.zh.reflectionQ1 -Label 'ZH reflectionQ1'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<div class="question-item"[^>]*data-number="2\."[^>]*>)(?<old>.*?)(?=</div>)' -NewValue $data.zh.reflectionQ2 -Label 'ZH reflectionQ2'
$zh = Replace-ByPattern -Text $zh -Pattern '(?<=<div class="tags-list"[^>]*>\s*)(?<old>.*?)(?=\s*</div>\s*</div>\s*</section>)' -NewValue (Join-Tags -Tags $data.zh.tags) -Label 'ZH tags'

# strip any junk before DOCTYPE that may have appeared from previous edits
$en = NormalizeHtml $en
$zh = NormalizeHtml $zh

Set-Content -LiteralPath $enFile -Value $en -Encoding UTF8
Set-Content -LiteralPath $zhFile -Value $zh -Encoding UTF8

# create ASCII alias for Chinese page so both paths work
$zhAlias = Join-Path $repoRoot 'public/zh/daily-commentary.html'
$aliasContent = "<!DOCTYPE html><html lang='zh-CN'><head><meta charset='UTF-8'><meta http-equiv='refresh' content='0; url=每日热点评论.html'><link rel='canonical' href='每日热点评论.html'></head><body></body></html>"
Set-Content -LiteralPath $zhAlias -Value $aliasContent -Encoding UTF8

Write-Host "Updated: public/en/daily-commentary.html"
Write-Host "Updated: public/zh/每日热点评论.html"
Write-Host "Created alias: public/zh/daily-commentary.html"

if ($Deploy) {
    $headline = "$($data.en.headline)".Trim()
    if ([string]::IsNullOrWhiteSpace($headline)) {
        $headline = 'daily commentary update'
    }

    & git -C $repoRoot add "public/en/daily-commentary.html" "public/zh/每日热点评论.html" "public/zh/daily-commentary.html"
    & git -C $repoRoot commit -m "publish: daily commentary - $headline"
    & git -C $repoRoot push

    Write-Host 'Git commit and push complete; deployment platform will auto-publish.'
}

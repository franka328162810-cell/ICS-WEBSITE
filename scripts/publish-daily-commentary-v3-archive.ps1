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

function Archive-PreviousCommentary {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnFilePath,
        [Parameter(Mandatory = $true)]
        [string]$ZhFilePath,
        [Parameter(Mandatory = $true)]
        [string]$EnArchivePath,
        [Parameter(Mandatory = $true)]
        [string]$ZhArchivePath,
        [Parameter(Mandatory = $true)]
        [string]$Headline,
        [Parameter(Mandatory = $true)]
        [string]$DateStr
    )

    # 生成存档文件名: news-daily-YYYYMMDD.html
    $timestamp = Get-Date -Format 'yyyyMMdd'
    $enArchiveFile = Join-Path (Split-Path $EnArchivePath) "news-daily-$timestamp.html"
    $zhArchiveFile = Join-Path (Split-Path $ZhArchivePath) "news-daily-$timestamp.html"

    # 读取当前内容（发布前）
    if (Test-Path $EnFilePath) {
        $enContent = Get-Content -LiteralPath $EnFilePath -Raw -Encoding UTF8
        Set-Content -LiteralPath $enArchiveFile -Value $enContent -Encoding UTF8
        Write-Host "已存档英文评论: $(Split-Path $enArchiveFile -Leaf)"
    }

    if (Test-Path $ZhFilePath) {
        $zhContent = Get-Content -LiteralPath $ZhFilePath -Raw -Encoding UTF8
        Set-Content -LiteralPath $zhArchiveFile -Value $zhContent -Encoding UTF8
        Write-Host "已存档中文评论: $(Split-Path $zhArchiveFile -Leaf)"
    }

    return @{
        EnFile = $enArchiveFile
        ZhFile = $zhArchiveFile
        Headline = $Headline
        Date = $DateStr
    }
}

function Update-ArchiveIndex {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveDir,
        [Parameter(Mandatory = $true)]
        [string]$Language
    )

    $newsFiles = Get-ChildItem -LiteralPath $ArchiveDir -Filter 'news-daily-*.html' | Sort-Object -Descending
    
    $archiveList = @()
    foreach ($file in $newsFiles) {
        if ($file.Name -match 'news-daily-(\d{8})') {
            $dateStr = $matches[1]
            $date = [datetime]::ParseExact($dateStr, 'yyyyMMdd', $null)
            
            if ($Language -eq 'en') {
                $dateFormatted = $date.ToString('MMMM d, yyyy', [System.Globalization.CultureInfo]::InvariantCulture)
            } else {
                $dateFormatted = $date.ToString('yyyy年M月d日', [System.Globalization.CultureInfo]::GetCultureInfo('zh-CN'))
            }
            
            $archiveList += @{
                File = $file.Name
                Date = $dateFormatted
                DateObj = $date
            }
        }
    }

    $archiveList = $archiveList | Sort-Object { $_.DateObj } -Descending

    return $archiveList
}

# ==================== MAIN ====================

$repoRoot = Split-Path -Parent $PSScriptRoot
$contentPath = if ([System.IO.Path]::IsPathRooted($ContentFile)) { $ContentFile } else { Join-Path $repoRoot $ContentFile }

if (-not (Test-Path -LiteralPath $contentPath)) {
    throw "内容文件不存在：$contentPath"
}

$data = Get-Content -LiteralPath $contentPath -Raw -Encoding UTF8 | ConvertFrom-Json

$enFile = Join-Path $repoRoot 'public/en/daily-commentary.html'
$zhFile = Join-Path $repoRoot 'public/zh/每日热点评论.html'
$enArchiveDir = Join-Path $repoRoot 'public/en/news'
$zhArchiveDir = Join-Path $repoRoot 'public/zh/news'
$enArchivePage = Join-Path $repoRoot 'public/en/news-archive.html'
$zhArchivePage = Join-Path $repoRoot 'public/zh/每日热点评论归档.html'

# ✅ 步骤1: 存档旧内容
Write-Host "步骤 1: 存档旧的每日评论..."
$archived = Archive-PreviousCommentary -EnFilePath $enFile -ZhFilePath $zhFile `
    -EnArchivePath $enArchiveDir -ZhArchivePath $zhArchiveDir `
    -Headline $data.en.headline -DateStr $data.en.date

# ✅ 步骤2: 更新当日页面
Write-Host "步骤 2: 更新当日评论页面..."
$en = Get-Content -LiteralPath $enFile -Raw -Encoding UTF8
$zh = Get-Content -LiteralPath $zhFile -Raw -Encoding UTF8

# 英文版
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

# 中文版
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

Write-Host "已更新当日评论页面"

# ✅ 步骤3: 更新归档索引
Write-Host "步骤 3: 生成/更新归档索引..."
$enArchives = Update-ArchiveIndex -ArchiveDir $enArchiveDir -Language 'en'
$zhArchives = Update-ArchiveIndex -ArchiveDir $zhArchiveDir -Language 'zh'

Write-Host "找到 $($enArchives.Count) 篇英文存档和 $($zhArchives.Count) 篇中文存档"

# ✅ 步骤4: Git 提交
if ($Deploy) {
    Write-Host "步骤 4: Git 提交与部署..."
    
    $headline = "$($data.en.headline)".Trim()
    if ([string]::IsNullOrWhiteSpace($headline)) {
        $headline = 'daily commentary update'
    }

    & git -C $repoRoot add "public/en/daily-commentary.html" "public/zh/每日热点评论.html" "public/en/news/" "public/zh/news/" "public/en/news-archive.html" "public/zh/每日热点评论归档.html"
    & git -C $repoRoot commit -m "publish: daily commentary - $headline (with archive)"
    & git -C $repoRoot push

    Write-Host "✅ 完成：已发布评论、存档旧文章、更新索引并推送到远程仓库"
} else {
    Write-Host "✅ 完成：已发布评论、存档旧文章、更新索引（未部署）"
    Write-Host "下次运行时添加 -Deploy 参数来部署到线上"
}

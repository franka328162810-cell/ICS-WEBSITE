param(
    [Parameter(Mandatory=$true)]
    [string]$ContentFile,
    [switch]$Deploy,
    [string]$WorkspaceRoot = (Get-Location).Path
)

function Write-ColorOutput {
    param([string]$Text, [string]$ForegroundColor = "White")
    Write-Host $Text -ForegroundColor $ForegroundColor
}

function Resolve-ZhPageByMarker {
    param([string]$Root, [string]$Marker)
    $zhDir = Join-Path $Root "public/zh"
    $files = Get-ChildItem -Path $zhDir -Filter "*.html" -File
    foreach ($f in $files) {
        $raw = Get-Content -Raw -Path $f.FullName -Encoding UTF8
        if ($raw -match $Marker) { return $f.FullName }
    }
    throw "Cannot resolve zh page with marker: $Marker"
}

function Replace-ByPattern {
    param([string]$Text, [string]$Pattern, [string]$NewValue)
    $safeName = [regex]::Escape($Pattern)
    return $Text -replace "(?<pre><span[^>]*data-field=\"$safeName\"[^>]*>)(.*?)(?<post></span>)", "`${pre}$([regex]::Replace($NewValue, '&', '&amp;') -replace '\"', '\"\"')`${post}"
}

function Join-Tags {
    param([object]$TagArray)
    if (!$TagArray) { return "" }
    $tags = @()
    foreach ($tag in $TagArray) { $tags += "<span class=\"tag\">$tag</span>" }
    return $tags -join " "
}

function Convert-ToIsoDate {
    param([string]$InputDate)
    if ([string]::IsNullOrWhiteSpace($InputDate)) { return (Get-Date).ToString("yyyy-MM-dd") }
    if ($InputDate -match '^\d{4}-\d{2}-\d{2}$') { return $InputDate }
    if ($InputDate -match '^(\d{4})年(\d{1,2})月(\d{1,2})日$') { return "{0}-{1:D2}-{2:D2}" -f [int]$matches[1], [int]$matches[2], [int]$matches[3] }
    try { return (Get-Date $InputDate).ToString("yyyy-MM-dd") } catch { return (Get-Date).ToString("yyyy-MM-dd") }
}

function Get-DailySeoBlock {
    param([string]$Headline,[string]$Category,[string]$Summary,[string]$Author,[string]$PublishedDate,[string]$Url)

    $desc = if ($Summary.Length -gt 160) { $Summary.Substring(0,160) + "..." } else { $Summary }
    $wordCount = ([regex]::Matches("$Headline $Summary", '\S+')).Count
    $titleEsc = [System.Net.WebUtility]::HtmlEncode($Headline)
    $descEsc = [System.Net.WebUtility]::HtmlEncode($desc)
    $catEsc = [System.Net.WebUtility]::HtmlEncode($Category)
    $authorEsc = [System.Net.WebUtility]::HtmlEncode($Author)

    $jsonLd = '{"@context":"https://schema.org","@type":"ScholarlyArticle","headline":"' + $titleEsc + '","author":{"@type":"Person","name":"' + $authorEsc + '"},"datePublished":"' + $PublishedDate + '","publisher":{"@type":"Organization","name":"Interstellar Civilization Studies","logo":{"@type":"ImageObject","url":"https://ics-studies.org/images/logo/ics-logo.png"}},"description":"' + $descEsc + '","articleSection":"' + $catEsc + '","wordCount":"' + $wordCount + '","mainEntityOfPage":"' + $Url + '"}'

    return "<!-- ICS-SEO-START (AUTO, DO NOT EDIT) -->`r`n<meta name=\"description\" content=\"$descEsc\">`r`n<meta property=\"og:type\" content=\"article\">`r`n<meta property=\"og:title\" content=\"$titleEsc\">`r`n<meta property=\"og:description\" content=\"$descEsc\">`r`n<meta property=\"og:url\" content=\"$Url\">`r`n<meta name=\"twitter:card\" content=\"summary_large_image\">`r`n<meta name=\"twitter:title\" content=\"$titleEsc\">`r`n<meta name=\"twitter:description\" content=\"$descEsc\">`r`n<script type=\"application/ld+json\">$jsonLd</script>`r`n<!-- ICS-SEO-END -->"
}

function Ensure-SeoBlock {
    param([string]$Html,[string]$SeoBlock)
    if ($Html -match '<!-- ICS-SEO-START \(AUTO, DO NOT EDIT\) -->.*?<!-- ICS-SEO-END -->') {
        $Html = [regex]::Replace($Html,'<!-- ICS-SEO-START \(AUTO, DO NOT EDIT\) -->.*?<!-- ICS-SEO-END -->',[System.Text.RegularExpressions.MatchEvaluator]{ param($m) $SeoBlock },[System.Text.RegularExpressions.RegexOptions]::Singleline)
    } elseif ($Html -match '</head>') {
        $Html = $Html -replace '</head>', ($SeoBlock + "`r`n</head>")
    } else {
        throw "Mandatory SEO injection failed: </head> not found"
    }
    if (!($Html -match 'application/ld\+json') -or !($Html -match 'ICS-SEO-START')) { throw "Mandatory SEO validation failed" }
    return $Html
}

function Archive-PreviousCommentary {
    param([string]$EnFilePath,[string]$ZhFilePath,[string]$EnArchiveDir,[string]$ZhArchiveDir)
    if (!(Test-Path $EnArchiveDir)) { New-Item -ItemType Directory -Path $EnArchiveDir -Force | Out-Null }
    if (!(Test-Path $ZhArchiveDir)) { New-Item -ItemType Directory -Path $ZhArchiveDir -Force | Out-Null }
    $name = "news-daily-$(Get-Date -Format 'yyyyMMdd').html"
    if (Test-Path $EnFilePath) { Copy-Item -Path $EnFilePath -Destination (Join-Path $EnArchiveDir $name) -Force }
    if (Test-Path $ZhFilePath) { Copy-Item -Path $ZhFilePath -Destination (Join-Path $ZhArchiveDir $name) -Force }
}

if (!(Test-Path $ContentFile)) { Write-ColorOutput "Error: content file not found" "Red"; exit 1 }
$contentData = Get-Content -Raw -Path $ContentFile -Encoding UTF8 | ConvertFrom-Json
if (!$contentData.en.date) { Write-ColorOutput "Error: en.date is required" "Red"; exit 1 }

try {
    $enFile = Join-Path $WorkspaceRoot "public/en/daily-commentary.html"
    $zhFile = Resolve-ZhPageByMarker -Root $WorkspaceRoot -Marker 'data-page="news-daily"'
    $homepageEn = Join-Path $WorkspaceRoot "public/index.html"
    $homepageZh = Resolve-ZhPageByMarker -Root $WorkspaceRoot -Marker 'data-page="home"'

    Archive-PreviousCommentary -EnFilePath $enFile -ZhFilePath $zhFile -EnArchiveDir (Join-Path $WorkspaceRoot "public/en/news") -ZhArchiveDir (Join-Path $WorkspaceRoot "public/zh/news")

    $enUpdated = Get-Content -Raw -Path $enFile -Encoding UTF8
    $zhUpdated = Get-Content -Raw -Path $zhFile -Encoding UTF8

    $fields = @("date","category","headline","source","sourceTime","summary","newThreeViews","normative","longTermImpact","reflectionQ1","reflectionQ2")
    foreach ($f in $fields) {
        $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern $f -NewValue $contentData.en.$f
        $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern $f -NewValue $contentData.zh.$f
    }
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "tags" -NewValue (Join-Tags -TagArray $contentData.en.tags)
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "tags" -NewValue (Join-Tags -TagArray $contentData.zh.tags)

    $iso = Convert-ToIsoDate -InputDate $contentData.en.date
    $enUpdated = Ensure-SeoBlock -Html $enUpdated -SeoBlock (Get-DailySeoBlock -Headline $contentData.en.headline -Category $contentData.en.category -Summary $contentData.en.summary -Author "ICS Editorial Team" -PublishedDate $iso -Url "https://ics-studies.org/en/daily-commentary.html")
    $zhUpdated = Ensure-SeoBlock -Html $zhUpdated -SeoBlock (Get-DailySeoBlock -Headline $contentData.zh.headline -Category $contentData.zh.category -Summary $contentData.zh.summary -Author "ICS Editorial Team" -PublishedDate $iso -Url "https://ics-studies.org/zh/%E6%AF%8F%E6%97%A5%E7%83%AD%E7%82%B9%E8%AF%84%E8%AE%BA.html")

    Set-Content -Path $enFile -Value $enUpdated -Encoding UTF8 -NoNewline
    Set-Content -Path $zhFile -Value $zhUpdated -Encoding UTF8 -NoNewline

    # Homepage sync
    $enHome = Get-Content -Raw -Path $homepageEn -Encoding UTF8
    $enHome = $enHome -replace '(<span class="card-tag">Commentary</span>\s*<h3 class="card-title">)([^<]*)(</h3>)', "`${1}$($contentData.en.headline)`${3}"
    Set-Content -Path $homepageEn -Value $enHome -Encoding UTF8 -NoNewline

    $zhHome = Get-Content -Raw -Path $homepageZh -Encoding UTF8
    $counter = 0
    $zhHome = [regex]::Replace($zhHome, '(<h3 class="card-title">)([^<]*)(</h3>)', [System.Text.RegularExpressions.MatchEvaluator]{
        param($m)
        $script:counter++
        if ($script:counter -eq 1) { return $m.Groups[1].Value + $contentData.zh.headline + $m.Groups[3].Value }
        return $m.Value
    })
    Set-Content -Path $homepageZh -Value $zhHome -Encoding UTF8 -NoNewline

    if ($Deploy) {
        Push-Location $WorkspaceRoot
        git add $enFile $zhFile public/en/news/ public/zh/news/ $homepageEn $homepageZh
        git commit -m ("Daily commentary - " + $contentData.en.date)
        git push
        Pop-Location
    }

    Write-ColorOutput "Done: daily commentary published with mandatory SEO." "Green"
} catch {
    Write-ColorOutput ("Error: " + $_) "Red"
    exit 1
}

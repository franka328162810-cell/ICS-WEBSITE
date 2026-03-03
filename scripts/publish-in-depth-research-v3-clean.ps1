param(
    [Parameter(Mandatory=$true)]
    [string]$ContentFile,
    [switch]$Deploy,
    [string]$WorkspaceRoot = (Get-Location).Path
)

function Resolve-ZhPageByMarker {
    param([string]$Root, [string]$Marker)
    $files = Get-ChildItem -Path (Join-Path $Root "public/zh") -Filter "*.html" -File
    foreach ($f in $files) {
        $raw = Get-Content -Raw -Path $f.FullName -Encoding UTF8
        if ($raw -match $Marker) { return $f.FullName }
    }
    throw "Cannot resolve zh page with marker: $Marker"
}

function Replace-ByPattern {
    param([string]$Text,[string]$Pattern,[string]$NewValue)
    $safe = [regex]::Escape($Pattern)
    return $Text -replace "(?<pre><span[^>]*data-field=\"$safe\"[^>]*>)(.*?)(?<post></span>)", "`${pre}$([regex]::Replace($NewValue,'&','&amp;') -replace '\"','\"\"')`${post}"
}

function Replace-ByPatternMultiLine {
    param([string]$Text,[string]$Pattern,[string]$NewValue)
    $safe = [regex]::Escape($Pattern)
    return $Text -replace "(?<pre><div[^>]*data-field=\"$safe\"[^>]*>)(.*?)(?<post></div>)", "`${pre}$($NewValue -replace '\"','\"\"')`${post}"
}

function Join-List {
    param([object]$ListArray,[string]$ItemTag='li')
    if (!$ListArray) { return '' }
    $items=@(); foreach($i in $ListArray){ $items += "<$ItemTag>$i</$ItemTag>" }
    return $items -join "`n"
}

function Ensure-SeoBlock {
    param([string]$Html,[string]$SeoBlock)
    if ($Html -match '<!-- ICS-SEO-START \(AUTO, DO NOT EDIT\) -->.*?<!-- ICS-SEO-END -->') {
        $Html = [regex]::Replace($Html,'<!-- ICS-SEO-START \(AUTO, DO NOT EDIT\) -->.*?<!-- ICS-SEO-END -->',[System.Text.RegularExpressions.MatchEvaluator]{ param($m) $SeoBlock },[System.Text.RegularExpressions.RegexOptions]::Singleline)
    } elseif ($Html -match '</head>') {
        $Html = $Html -replace '</head>', ($SeoBlock + "`r`n</head>")
    } else {
        throw 'Mandatory SEO injection failed: </head> not found'
    }
    if (!($Html -match 'application/ld\+json')) { throw 'Mandatory SEO validation failed' }
    return $Html
}

function Get-ResearchSeoBlock {
    param([string]$Title,[string]$Author,[string]$Description,[string]$Url,[string]$BodyText)
    $desc = if ($Description.Length -gt 160) { $Description.Substring(0,160) + '...' } else { $Description }
    $wordCount = ([regex]::Matches("$Title $Description $BodyText",'\S+')).Count
    $titleEsc=[System.Net.WebUtility]::HtmlEncode($Title)
    $descEsc=[System.Net.WebUtility]::HtmlEncode($desc)
    $authorEsc=[System.Net.WebUtility]::HtmlEncode($Author)
    $jsonLd='{"@context":"https://schema.org","@type":"ScholarlyArticle","headline":"'+$titleEsc+'","author":{"@type":"Person","name":"'+$authorEsc+'"},"datePublished":"'+(Get-Date -Format 'yyyy-MM-dd')+'","publisher":{"@type":"Organization","name":"Interstellar Civilization Studies"},"description":"'+$descEsc+'","wordCount":"'+$wordCount+'","mainEntityOfPage":"'+$Url+'"}'
    return "<!-- ICS-SEO-START (AUTO, DO NOT EDIT) -->`r`n<meta name=\"description\" content=\"$descEsc\">`r`n<meta property=\"og:type\" content=\"article\">`r`n<meta property=\"og:title\" content=\"$titleEsc\">`r`n<meta property=\"og:description\" content=\"$descEsc\">`r`n<meta property=\"og:url\" content=\"$Url\">`r`n<script type=\"application/ld+json\">$jsonLd</script>`r`n<!-- ICS-SEO-END -->"
}

if (!(Test-Path $ContentFile)) { throw 'Content file not found' }
$contentData = Get-Content -Raw -Path $ContentFile -Encoding UTF8 | ConvertFrom-Json

$enFile = Join-Path $WorkspaceRoot 'public/en/in-depth-research.html'
$zhFile = Resolve-ZhPageByMarker -Root $WorkspaceRoot -Marker 'data-page="research-deep"'
$homeEn = Join-Path $WorkspaceRoot 'public/index.html'
$homeZh = Resolve-ZhPageByMarker -Root $WorkspaceRoot -Marker 'data-page="home"'

$en = Get-Content -Raw -Path $enFile -Encoding UTF8
$zh = Get-Content -Raw -Path $zhFile -Encoding UTF8

$en = Replace-ByPattern -Text $en -Pattern 'publicationWeek' -NewValue $contentData.en.publicationWeek
$en = Replace-ByPattern -Text $en -Pattern 'title' -NewValue $contentData.en.title
$en = Replace-ByPattern -Text $en -Pattern 'author' -NewValue $contentData.en.author
$en = Replace-ByPattern -Text $en -Pattern 'abstract' -NewValue $contentData.en.abstract
$en = Replace-ByPatternMultiLine -Text $en -Pattern 'keywords' -NewValue (Join-List -ListArray $contentData.en.keywords -ItemTag 'span')
$en = Replace-ByPattern -Text $en -Pattern 'mainSection1Title' -NewValue $contentData.en.mainSection1Title
$en = Replace-ByPatternMultiLine -Text $en -Pattern 'mainSection1Content' -NewValue $contentData.en.mainSection1Content
$en = Replace-ByPattern -Text $en -Pattern 'mainSection2Title' -NewValue $contentData.en.mainSection2Title
$en = Replace-ByPatternMultiLine -Text $en -Pattern 'mainSection2Content' -NewValue $contentData.en.mainSection2Content
$en = Replace-ByPattern -Text $en -Pattern 'mainSection3Title' -NewValue $contentData.en.mainSection3Title
$en = Replace-ByPatternMultiLine -Text $en -Pattern 'mainSection3Content' -NewValue $contentData.en.mainSection3Content
$en = Replace-ByPattern -Text $en -Pattern 'conclusionTitle' -NewValue $contentData.en.conclusionTitle
$en = Replace-ByPatternMultiLine -Text $en -Pattern 'conclusionContent' -NewValue $contentData.en.conclusionContent
$en = Replace-ByPatternMultiLine -Text $en -Pattern 'recommendations' -NewValue (Join-List -ListArray $contentData.en.recommendations)
$en = Replace-ByPatternMultiLine -Text $en -Pattern 'relatedTopics' -NewValue (Join-List -ListArray $contentData.en.relatedTopics -ItemTag 'span')
$en = Replace-ByPattern -Text $en -Pattern 'citationKey' -NewValue $contentData.en.citationKey
$en = Replace-ByPatternMultiLine -Text $en -Pattern 'acknowledgments' -NewValue $contentData.en.acknowledgments

$zh = Replace-ByPattern -Text $zh -Pattern 'publicationWeek' -NewValue $contentData.zh.publicationWeek
$zh = Replace-ByPattern -Text $zh -Pattern 'title' -NewValue $contentData.zh.title
$zh = Replace-ByPattern -Text $zh -Pattern 'author' -NewValue $contentData.zh.author
$zh = Replace-ByPattern -Text $zh -Pattern 'abstract' -NewValue $contentData.zh.abstract
$zh = Replace-ByPatternMultiLine -Text $zh -Pattern 'keywords' -NewValue (Join-List -ListArray $contentData.zh.keywords -ItemTag 'span')
$zh = Replace-ByPattern -Text $zh -Pattern 'mainSection1Title' -NewValue $contentData.zh.mainSection1Title
$zh = Replace-ByPatternMultiLine -Text $zh -Pattern 'mainSection1Content' -NewValue $contentData.zh.mainSection1Content
$zh = Replace-ByPattern -Text $zh -Pattern 'mainSection2Title' -NewValue $contentData.zh.mainSection2Title
$zh = Replace-ByPatternMultiLine -Text $zh -Pattern 'mainSection2Content' -NewValue $contentData.zh.mainSection2Content
$zh = Replace-ByPattern -Text $zh -Pattern 'mainSection3Title' -NewValue $contentData.zh.mainSection3Title
$zh = Replace-ByPatternMultiLine -Text $zh -Pattern 'mainSection3Content' -NewValue $contentData.zh.mainSection3Content
$zh = Replace-ByPattern -Text $zh -Pattern 'conclusionTitle' -NewValue $contentData.zh.conclusionTitle
$zh = Replace-ByPatternMultiLine -Text $zh -Pattern 'conclusionContent' -NewValue $contentData.zh.conclusionContent
$zh = Replace-ByPatternMultiLine -Text $zh -Pattern 'recommendations' -NewValue (Join-List -ListArray $contentData.zh.recommendations)
$zh = Replace-ByPatternMultiLine -Text $zh -Pattern 'relatedTopics' -NewValue (Join-List -ListArray $contentData.zh.relatedTopics -ItemTag 'span')
$zh = Replace-ByPattern -Text $zh -Pattern 'citationKey' -NewValue $contentData.zh.citationKey
$zh = Replace-ByPatternMultiLine -Text $zh -Pattern 'acknowledgments' -NewValue $contentData.zh.acknowledgments

$enBody = "$($contentData.en.mainSection1Content) $($contentData.en.mainSection2Content) $($contentData.en.mainSection3Content)"
$zhBody = "$($contentData.zh.mainSection1Content) $($contentData.zh.mainSection2Content) $($contentData.zh.mainSection3Content)"
$en = Ensure-SeoBlock -Html $en -SeoBlock (Get-ResearchSeoBlock -Title $contentData.en.title -Author $contentData.en.author -Description $contentData.en.abstract -Url 'https://ics-studies.org/en/in-depth-research.html' -BodyText $enBody)
$zh = Ensure-SeoBlock -Html $zh -SeoBlock (Get-ResearchSeoBlock -Title $contentData.zh.title -Author $contentData.zh.author -Description $contentData.zh.abstract -Url 'https://ics-studies.org/zh/%E6%B7%B1%E5%BA%A6%E7%A0%94%E7%A9%B6.html' -BodyText $zhBody)

Set-Content -Path $enFile -Value $en -Encoding UTF8 -NoNewline
Set-Content -Path $zhFile -Value $zh -Encoding UTF8 -NoNewline

$homeEnHtml = Get-Content -Raw -Path $homeEn -Encoding UTF8
$homeEnHtml = $homeEnHtml -replace '(<span class="card-tag">Research</span>\s*<h3 class="card-title">)([^<]*)(</h3>)', "`${1}$($contentData.en.title)`${3}"
Set-Content -Path $homeEn -Value $homeEnHtml -Encoding UTF8 -NoNewline

$homeZhHtml = Get-Content -Raw -Path $homeZh -Encoding UTF8
$idx=0
$homeZhHtml = [regex]::Replace($homeZhHtml, '(<h3 class="card-title">)([^<]*)(</h3>)', [System.Text.RegularExpressions.MatchEvaluator]{
    param($m)
    $script:idx++
    if ($script:idx -eq 2) { return $m.Groups[1].Value + $contentData.zh.title + $m.Groups[3].Value }
    return $m.Value
})
Set-Content -Path $homeZh -Value $homeZhHtml -Encoding UTF8 -NoNewline

if ($Deploy) {
    Push-Location $WorkspaceRoot
    git add $enFile $zhFile public/en/articles/ public/zh/articles/ $homeEn $homeZh
    git commit -m ("In-Depth Research - " + $contentData.en.publicationWeek)
    git push
    Pop-Location
}

Write-Host "Done: in-depth research published with mandatory SEO." -ForegroundColor Green

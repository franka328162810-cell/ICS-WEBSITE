param(
    [Parameter(Mandatory=$true)][string]$ContentFile,
    [Parameter(Mandatory=$false)][switch]$Deploy
)

function Write-ColorOutput { param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Inject-SeoBlock {
    param([string]$Html, [string]$Title, [string]$Date, [string]$IsEnglish)
    
    if ($IsEnglish) {
        $metaDesc = "Daily AI governance commentary: $Title"
        $author = "ICS Research Institute"
    } else {
        $metaDesc = "每日AI治理评论: $Title"
        $author = "星际文明研究所"
    }
    
    $seoBlock = @"
    <!-- ICS-SEO-START -->
    <meta name="description" content="$metaDesc">
    <meta property="og:type" content="article">
    <meta property="og:title" content="$Title">
    <meta property="og:description" content="$metaDesc">
    <meta property="article:published_time" content="$Date">
    <meta property="article:author" content="$author">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="$Title">
    <meta name="twitter:description" content="$metaDesc">
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "ScholarlyArticle",
      "headline": "$Title",
      "datePublished": "$Date",
      "author": {"@type": "Organization", "name": "$author"},
      "description": "$metaDesc"
    }
    </script>
    <!-- ICS-SEO-END -->
"@
    
    if ($Html -match '</head>') {
        $Html = $Html -replace '</head>', "$seoBlock`n</head>"
    } else {
        Write-ColorOutput "✗ SEO INJECTION FAILED: </head> tag not found! PUBLISH ABORTED." "Red"
        exit 1
    }
    
    if ($Html -match '<!-- ICS-SEO-START -->') {
        return $Html
    } else {
        Write-ColorOutput "✗ SEO VALIDATION FAILED: SEO block not found after injection! PUBLISH ABORTED." "Red"
        exit 1
    }
}

function Replace-Field {
    param([string]$Html, [string]$FieldName, [string]$Value)
    
    $pattern = "<span[^>]*data-field=`"$FieldName`"[^>]*>.*?</span>"
    $replacement = "<span data-field=`"$FieldName`">$Value</span>"
    
    return [regex]::Replace($Html, $pattern, $replacement)
}

Write-ColorOutput "Publishing Daily Commentary (Quick SEO Test)" "Cyan"

if (!(Test-Path $ContentFile)) {
    Write-ColorOutput "Error: Content file not found" "Red"
    exit 1
}

$contentData = Get-Content -Raw -Path $ContentFile -Encoding UTF8 | ConvertFrom-Json
$WorkspaceRoot = Split-Path $ContentFile -Parent | Split-Path -Parent

$enFile = Join-Path $WorkspaceRoot "public" | Join-Path -ChildPath "en" | Join-Path -ChildPath "daily-commentary.html"
$zhFile = Join-Path $WorkspaceRoot "public" | Join-Path -ChildPath "zh" | Join-Path -ChildPath ([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("每日热点评论.html")))

Write-ColorOutput "EN File: $enFile" "Yellow"
Write-ColorOutput "ZH File: $zhFile" "Yellow"

Write-ColorOutput "`n[Step 1] Loading templates..." "Magenta"
$enTemplate = Get-Content -Raw -Path $enFile -Encoding UTF8
$zhTemplate = Get-Content -Raw -Path $zhFile -Encoding UTF8

Write-ColorOutput "`n[Step 2] Updating EN content..." "Magenta"
$enUpdated = $enTemplate
$enUpdated = Replace-Field -Html $enUpdated -FieldName "date" -Value $contentData.en.date
$enUpdated = Replace-Field -Html $enUpdated -FieldName "category" -Value $contentData.en.category
$enUpdated = Replace-Field -Html $enUpdated -FieldName "headline" -Value $contentData.en.headline
$enUpdated = Replace-Field -Html $enUpdated -FieldName "source" -Value $contentData.en.source
$enUpdated = Replace-Field -Html $enUpdated -FieldName "sourceTime" -Value $contentData.en.sourceTime
$enUpdated = Replace-Field -Html $enUpdated -FieldName "summary" -Value $contentData.en.summary
$enUpdated = Replace-Field -Html $enUpdated -FieldName "newThreeViews" -Value $contentData.en.newThreeViews
$enUpdated = Replace-Field -Html $enUpdated -FieldName "normative" -Value $contentData.en.normative
$enUpdated = Replace-Field -Html $enUpdated -FieldName "longTermImpact" -Value $contentData.en.longTermImpact
$enUpdated = Replace-Field -Html $enUpdated -FieldName "reflectionQ1" -Value $contentData.en.reflectionQ1
$enUpdated = Replace-Field -Html $enUpdated -FieldName "reflectionQ2" -Value $contentData.en.reflectionQ2
$tagStr = if ($contentData.en.tags -is [array]) { $contentData.en.tags -join ", " } else { $contentData.en.tags }
$enUpdated = Replace-Field -Html $enUpdated -FieldName "tags" -Value $tagStr

Write-ColorOutput "`n[Step 3] Injecting MANDATORY SEO block (EN)..." "Magenta"
$enUpdated = Inject-SeoBlock -Html $enUpdated -Title $contentData.en.headline -Date $contentData.en.date -IsEnglish $true

Write-ColorOutput "`n[Step 4] Updating ZH content..." "Magenta"
$zhUpdated = $zhTemplate
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "date" -Value $contentData.zh.date
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "category" -Value $contentData.zh.category
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "headline" -Value $contentData.zh.headline
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "source" -Value $contentData.zh.source
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "sourceTime" -Value $contentData.zh.sourceTime
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "summary" -Value $contentData.zh.summary
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "newThreeViews" -Value $contentData.zh.newThreeViews
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "normative" -Value $contentData.zh.normative
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "longTermImpact" -Value $contentData.zh.longTermImpact
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "reflectionQ1" -Value $contentData.zh.reflectionQ1
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "reflectionQ2" -Value $contentData.zh.reflectionQ2
$zhTagStr = if ($contentData.zh.tags -is [array]) { $contentData.zh.tags -join "," } else { $contentData.zh.tags }
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "tags" -Value $zhTagStr

Write-ColorOutput "`n[Step 5] Injecting MANDATORY SEO block (ZH)..." "Magenta"
$zhUpdated = Inject-SeoBlock -Html $zhUpdated -Title $contentData.zh.headline -Date $contentData.zh.date -IsEnglish $false

Write-ColorOutput "`n[Step 6] Writing files..." "Magenta"
Set-Content -Path $enFile -Value $enUpdated -Encoding UTF8 -NoNewline
Set-Content -Path $zhFile -Value $zhUpdated -Encoding UTF8 -NoNewline

Write-ColorOutput "`n✓ Daily Commentary published successfully with SEO!" "Green"
Write-ColorOutput "EN: $enFile" "Green"
Write-ColorOutput "ZH: $zhFile" "Green"

if ($Deploy) {
    Write-ColorOutput "`n[Step 7] Deploying to git..." "Magenta"
    Push-Location $WorkspaceRoot
    git add "public/en/daily-commentary.html" "public/zh/每日热点评论.html"
    git commit -m "chore: update daily commentary (SEO-enforced) - Trump Anthropic ban"
    git push
    Pop-Location
    Write-ColorOutput "✓ Deployed!" "Green"
}

exit 0

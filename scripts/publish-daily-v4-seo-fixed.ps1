param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]$ContentFile,
    [Parameter(Mandatory=$false)][switch]$Deploy,
    [Parameter(Mandatory=$false)][string]$WorkspaceRoot = (Get-Location).Path
)

function Write-ColorOutput { param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

# ===== VALIDATION: Layout Consistency (Zero Tolerance) =====
function Validate-LayoutConsistency {
    param([string]$EnFile, [string]$ZhFile)
    Write-ColorOutput "`n[Pre-Publish] Validating layout consistency..." "Yellow"
    
    $enContent = Get-Content -Raw -Path $EnFile -Encoding UTF8
    $zhContent = Get-Content -Raw -Path $ZhFile -Encoding UTF8
    
    # Normalize: Extract only <span data-field="X"> markers, remove values
    $enNorm = [regex]::Replace($enContent, '(<span[^>]*data-field=")[^"]*(")', '$1__FIELD__$2')
    $zhNorm = [regex]::Replace($zhContent, '(<span[^>]*data-field=")[^"]*(")', '$1__FIELD__$2')
    
    # Remove all text nodes for comparison
    $enStruct = [regex]::Replace($enNorm, '>[^<]*<', '><')
    $zhStruct = [regex]::Replace($zhNorm, '>[^<]*<', '><')
    
    if ($enStruct -eq $zhStruct) {
        Write-ColorOutput "鉁?Layout 100% consistent EN/ZH" "Green"
        return $true
    } else {
        Write-ColorOutput "鉁?Layout mismatch detected! Publish aborted." "Red"
        exit 1
    }
}

# ===== SEO: Mandatory Injection & Validation =====
function Inject-SeoBlock {
    param([string]$Html, [string]$Title, [string]$Date, [string]$IsEnglish)
    
    if ($IsEnglish) {
        $metaDesc = "Daily AI governance commentary: $Title"
        $author = "Institute for Cosmic Stewardship"
    } else {
        $metaDesc = "姣忔棩AI娌荤悊璇勮: $Title"
        $author = "瀹囧畽绠＄悊鐮旂┒鎵€"
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
    
    # Inject before </head>
    if ($Html -match '</head>') {
        $Html = $Html -replace '</head>', "$seoBlock`n</head>"
    } else {
        Write-ColorOutput "鉁?SEO INJECTION FAILED: </head> tag not found! PUBLISH ABORTED." "Red"
        exit 1
    }
    
    # Validate injection
    if ($Html -match '<!-- ICS-SEO-START -->') {
        return $Html
    } else {
        Write-ColorOutput "鉁?SEO VALIDATION FAILED: SEO block not found after injection! PUBLISH ABORTED." "Red"
        exit 1
    }
}

# ===== Simple Field Replacement =====
function Replace-Field {
    param([string]$Html, [string]$FieldName, [string]$Value)
    
    $pattern = "<span[^>]*data-field=`"$FieldName`"[^>]*>.*?</span>"
    $replacement = "<span data-field=`"$FieldName`">$Value</span>"
    
    return [regex]::Replace($Html, $pattern, $replacement)
}

# ===== MAIN WORKFLOW =====
Write-ColorOutput "Publishing Daily Commentary v4 (SEO-Enforced)" "Cyan"

if (!(Test-Path $ContentFile)) {
    Write-ColorOutput "Error: Content file not found" "Red"
    exit 1
}

$contentData = Get-Content -Raw -Path $ContentFile | ConvertFrom-Json

$enFile = Join-Path $WorkspaceRoot "public/en/daily-commentary.html"
$zhFile = Join-Path $WorkspaceRoot "public/zh/每日热点评论.html"

# Step 1: Validate layout
Validate-LayoutConsistency -EnFile $enFile -ZhFile $zhFile

# Step 2: Load templates
Write-ColorOutput "`n[Step 2] Loading templates..." "Magenta"
$enTemplate = Get-Content -Raw -Path $enFile -Encoding UTF8
$zhTemplate = Get-Content -Raw -Path $zhFile -Encoding UTF8

# Step 3: Update EN content
Write-ColorOutput "`n[Step 3] Updating EN content..." "Magenta"
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
$enUpdated = Replace-Field -Html $enUpdated -FieldName "tags" -Value $contentData.en.tags

# Step 4: Inject SEO (MANDATORY)
Write-ColorOutput "`n[Step 4] Injecting MANDATORY SEO block (EN)..." "Magenta"
$enUpdated = Inject-SeoBlock -Html $enUpdated -Title $contentData.en.headline -Date $contentData.en.date -IsEnglish $true

# Step 5: Update ZH content
Write-ColorOutput "`n[Step 5] Updating ZH content..." "Magenta"
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
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "tags" -Value $contentData.zh.tags

# Step 6: Inject SEO (MANDATORY)
Write-ColorOutput "`n[Step 6] Injecting MANDATORY SEO block (ZH)..." "Magenta"
$zhUpdated = Inject-SeoBlock -Html $zhUpdated -Title $contentData.zh.headline -Date $contentData.zh.date -IsEnglish $false

# Step 7: Write files
Write-ColorOutput "`n[Step 7] Writing files..." "Magenta"
Set-Content -Path $enFile -Value $enUpdated -Encoding UTF8 -NoNewline
Set-Content -Path $zhFile -Value $zhUpdated -Encoding UTF8 -NoNewline

Write-ColorOutput "`n鉁?Daily Commentary published successfully with SEO!" "Green"
Write-ColorOutput "EN: $enFile" "Green"
Write-ColorOutput "ZH: $zhFile" "Green"

if ($Deploy) {
    Write-ColorOutput "`n[Step 8] Deploying to git..." "Magenta"
    Push-Location $WorkspaceRoot
    git add public/en/daily-commentary.html $zhFile
    git commit -m "chore: update daily commentary with SEO optimization"
    git push
    Pop-Location
    Write-ColorOutput "鉁?Deployed!" "Green"
}

exit 0


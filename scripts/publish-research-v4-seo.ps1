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
        Write-ColorOutput "✓ Layout 100% consistent EN/ZH" "Green"
        return $true
    } else {
        Write-ColorOutput "✗ Layout mismatch detected! Publish aborted." "Red"
        exit 1
    }
}

# ===== SEO: Mandatory Injection & Validation =====
function Inject-SeoBlock {
    param([string]$Html, [string]$Title, [string]$Date, [string]$Author, [string]$IsEnglish)
    
    if ($IsEnglish) {
        $metaDesc = "In-depth research: $Title"
        $publisher = "Institute for Cosmic Stewardship"
    } else {
        $metaDesc = "深度研究: $Title"
        $publisher = "宇宙管理研究所"
    }
    
    $seoBlock = @"
    <!-- ICS-SEO-START -->
    <meta name="description" content="$metaDesc">
    <meta property="og:type" content="article">
    <meta property="og:title" content="$Title">
    <meta property="og:description" content="$metaDesc">
    <meta property="article:published_time" content="$Date">
    <meta property="article:author" content="$Author">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="$Title">
    <meta name="twitter:description" content="$metaDesc">
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "ScholarlyArticle",
      "headline": "$Title",
      "datePublished": "$Date",
      "author": {"@type": "Person", "name": "$Author"},
      "publisher": {"@type": "Organization", "name": "$publisher"},
      "description": "$metaDesc"
    }
    </script>
    <!-- ICS-SEO-END -->
"@
    
    # Inject before </head>
    if ($Html -match '</head>') {
        $Html = $Html -replace '</head>', "$seoBlock`n</head>"
    } else {
        Write-ColorOutput "✗ SEO INJECTION FAILED: </head> tag not found! PUBLISH ABORTED." "Red"
        exit 1
    }
    
    # Validate injection
    if ($Html -match '<!-- ICS-SEO-START -->') {
        return $Html
    } else {
        Write-ColorOutput "✗ SEO VALIDATION FAILED: SEO block not found after injection! PUBLISH ABORTED." "Red"
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
Write-ColorOutput "Publishing In-Depth Research v4 (SEO-Enforced)" "Cyan"

if (!(Test-Path $ContentFile)) {
    Write-ColorOutput "Error: Content file not found" "Red"
    exit 1
}

$contentData = Get-Content -Raw -Path $ContentFile | ConvertFrom-Json

$enFile = Join-Path $WorkspaceRoot "public/en/in-depth-research.html"
$zhFile = Join-Path $WorkspaceRoot "public/zh/深度研究.html"

if (!(Test-Path $zhFile)) {
    $zhFile = Join-Path $WorkspaceRoot "public/zh/research-deep-2.html"
}

# Step 1: Validate layout
Validate-LayoutConsistency -EnFile $enFile -ZhFile $zhFile

# Step 2: Load templates
Write-ColorOutput "`n[Step 2] Loading templates..." "Magenta"
$enTemplate = Get-Content -Raw -Path $enFile -Encoding UTF8
$zhTemplate = Get-Content -Raw -Path $zhFile -Encoding UTF8

# Step 3: Update EN content
Write-ColorOutput "`n[Step 3] Updating EN content..." "Magenta"
$enUpdated = $enTemplate
$enUpdated = Replace-Field -Html $enUpdated -FieldName "publicationWeek" -Value $contentData.en.publicationWeek
$enUpdated = Replace-Field -Html $enUpdated -FieldName "title" -Value $contentData.en.title
$enUpdated = Replace-Field -Html $enUpdated -FieldName "author" -Value $contentData.en.author
$enUpdated = Replace-Field -Html $enUpdated -FieldName "abstract" -Value $contentData.en.abstract
$enUpdated = Replace-Field -Html $enUpdated -FieldName "keywords" -Value $contentData.en.keywords
$enUpdated = Replace-Field -Html $enUpdated -FieldName "mainSection1Title" -Value $contentData.en.mainSection1Title
$enUpdated = Replace-Field -Html $enUpdated -FieldName "mainSection1Content" -Value $contentData.en.mainSection1Content
$enUpdated = Replace-Field -Html $enUpdated -FieldName "mainSection2Title" -Value $contentData.en.mainSection2Title
$enUpdated = Replace-Field -Html $enUpdated -FieldName "mainSection2Content" -Value $contentData.en.mainSection2Content
$enUpdated = Replace-Field -Html $enUpdated -FieldName "mainSection3Title" -Value $contentData.en.mainSection3Title
$enUpdated = Replace-Field -Html $enUpdated -FieldName "mainSection3Content" -Value $contentData.en.mainSection3Content
$enUpdated = Replace-Field -Html $enUpdated -FieldName "conclusionTitle" -Value $contentData.en.conclusionTitle
$enUpdated = Replace-Field -Html $enUpdated -FieldName "conclusionContent" -Value $contentData.en.conclusionContent
$enUpdated = Replace-Field -Html $enUpdated -FieldName "recommendations" -Value $contentData.en.recommendations
$enUpdated = Replace-Field -Html $enUpdated -FieldName "relatedTopics" -Value $contentData.en.relatedTopics
$enUpdated = Replace-Field -Html $enUpdated -FieldName "citationKey" -Value $contentData.en.citationKey

# Step 4: Inject SEO (MANDATORY)
Write-ColorOutput "`n[Step 4] Injecting MANDATORY SEO block (EN)..." "Magenta"
$enUpdated = Inject-SeoBlock -Html $enUpdated -Title $contentData.en.title -Date $contentData.en.publicationWeek -Author $contentData.en.author -IsEnglish $true

# Step 5: Update ZH content
Write-ColorOutput "`n[Step 5] Updating ZH content..." "Magenta"
$zhUpdated = $zhTemplate
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "publicationWeek" -Value $contentData.zh.publicationWeek
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "title" -Value $contentData.zh.title
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "author" -Value $contentData.zh.author
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "abstract" -Value $contentData.zh.abstract
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "keywords" -Value $contentData.zh.keywords
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "mainSection1Title" -Value $contentData.zh.mainSection1Title
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "mainSection1Content" -Value $contentData.zh.mainSection1Content
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "mainSection2Title" -Value $contentData.zh.mainSection2Title
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "mainSection2Content" -Value $contentData.zh.mainSection2Content
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "mainSection3Title" -Value $contentData.zh.mainSection3Title
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "mainSection3Content" -Value $contentData.zh.mainSection3Content
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "conclusionTitle" -Value $contentData.zh.conclusionTitle
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "conclusionContent" -Value $contentData.zh.conclusionContent
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "recommendations" -Value $contentData.zh.recommendations
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "relatedTopics" -Value $contentData.zh.relatedTopics
$zhUpdated = Replace-Field -Html $zhUpdated -FieldName "citationKey" -Value $contentData.zh.citationKey

# Step 6: Inject SEO (MANDATORY)
Write-ColorOutput "`n[Step 6] Injecting MANDATORY SEO block (ZH)..." "Magenta"
$zhUpdated = Inject-SeoBlock -Html $zhUpdated -Title $contentData.zh.title -Date $contentData.zh.publicationWeek -Author $contentData.zh.author -IsEnglish $false

# Step 7: Write files
Write-ColorOutput "`n[Step 7] Writing files..." "Magenta"
Set-Content -Path $enFile -Value $enUpdated -Encoding UTF8 -NoNewline
Set-Content -Path $zhFile -Value $zhUpdated -Encoding UTF8 -NoNewline

Write-ColorOutput "`n✓ In-Depth Research published successfully with SEO!" "Green"
Write-ColorOutput "EN: $enFile" "Green"
Write-ColorOutput "ZH: $zhFile" "Green"

if ($Deploy) {
    Write-ColorOutput "`n[Step 8] Deploying to git..." "Magenta"
    Push-Location $WorkspaceRoot
    git add public/en/in-depth-research.html $zhFile
    git commit -m "chore: update in-depth research with SEO optimization"
    git push
    Pop-Location
    Write-ColorOutput "✓ Deployed!" "Green"
}

exit 0

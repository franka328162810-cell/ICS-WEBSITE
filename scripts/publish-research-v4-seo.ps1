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
        Write-ColorOutput "Layout 100% consistent EN/ZH" "Green"
        return $true
    } else {
        Write-ColorOutput "鉁?Layout mismatch detected! Publish aborted." "Red"
        exit 1
    }
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$scriptRoot\seo_common.ps1"

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
$zhFile = Join-Path $WorkspaceRoot "public/zh/娣卞害鐮旂┒.html"

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
$enUpdated = Inject-SeoBlock -Html $enUpdated -Title $contentData.en.title -Description $contentData.en.abstract -Url "https://ics-studies.org/en/in-depth-research.html" -Locale "en" -AlternateLocale "zh" -AlternateUrl "https://ics-studies.org/zh/娣卞害鐮旂┒.html" -SiteName "Interstellar Civilization Studies" -Author $contentData.en.author -PublishedTime $contentData.en.publicationWeek
Validate-SeoTags -Html $enUpdated -Path $enFile

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
$zhUrl = if ($zhFile -match '娣卞害鐮旂┒\.html$') { "https://ics-studies.org/zh/娣卞害鐮旂┒.html" } else { "https://ics-studies.org/zh/research-deep-2.html" }
$zhUpdated = Inject-SeoBlock -Html $zhUpdated -Title $contentData.zh.title -Description $contentData.zh.abstract -Url $zhUrl -Locale "zh" -AlternateLocale "en" -AlternateUrl "https://ics-studies.org/en/in-depth-research.html" -SiteName "星际文明学" -Author $contentData.zh.author -PublishedTime $contentData.zh.publicationWeek
Validate-SeoTags -Html $zhUpdated -Path $zhFile

# Step 7: Write files
Write-ColorOutput "`n[Step 7] Writing files..." "Magenta"
Set-Content -Path $enFile -Value $enUpdated -Encoding UTF8 -NoNewline
Set-Content -Path $zhFile -Value $zhUpdated -Encoding UTF8 -NoNewline

Write-ColorOutput "`nIn-Depth Research published successfully with SEO!" "Green"
Write-ColorOutput "EN: $enFile" "Green"
Write-ColorOutput "ZH: $zhFile" "Green"

if ($Deploy) {
    Write-ColorOutput "`n[Step 8] Deploying to git..." "Magenta"
    Push-Location $WorkspaceRoot
    git add public/en/in-depth-research.html $zhFile
    git commit -m "chore: update in-depth research with SEO optimization"
    git push
    Pop-Location
    Write-ColorOutput "Deployed!" "Green"
}

exit 0


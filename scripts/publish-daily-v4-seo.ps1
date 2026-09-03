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
Write-ColorOutput "Publishing Daily Commentary v4 (SEO-Enforced)" "Cyan"

if (!(Test-Path $ContentFile)) {
    Write-ColorOutput "Error: Content file not found" "Red"
    exit 1
}

$contentData = Get-Content -Raw -Path $ContentFile | ConvertFrom-Json

$enFile = Join-Path $WorkspaceRoot "public/en/daily-commentary.html"
$zhFile = Join-Path $WorkspaceRoot "public/zh/姣忔棩鐑偣璇勮.html"

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
$enUpdated = Inject-SeoBlock -Html $enUpdated -Title $contentData.en.headline -Description $contentData.en.summary -Url "https://ics-studies.org/en/daily-commentary.html" -Locale "en" -AlternateLocale "zh" -AlternateUrl "https://ics-studies.org/zh/姣忔棩鐑偣璇勮.html" -SiteName "Interstellar Civilization Studies" -Author "ICS Research Institute" -PublishedTime $contentData.en.date
Validate-SeoTags -Html $enUpdated -Path $enFile

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
$zhUpdated = Inject-SeoBlock -Html $zhUpdated -Title $contentData.zh.headline -Description $contentData.zh.summary -Url "https://ics-studies.org/zh/每日热点评论.html" -Locale "zh" -AlternateLocale "en" -AlternateUrl "https://ics-studies.org/en/daily-commentary.html" -SiteName "星际文明学" -Author "星际文明研究所" -PublishedTime $contentData.zh.date
Validate-SeoTags -Html $zhUpdated -Path $zhFile

# Step 7: Write files
Write-ColorOutput "`n[Step 7] Writing files..." "Magenta"
Set-Content -Path $enFile -Value $enUpdated -Encoding UTF8 -NoNewline
Set-Content -Path $zhFile -Value $zhUpdated -Encoding UTF8 -NoNewline

Write-ColorOutput "`nDaily Commentary published successfully with SEO!" "Green"
Write-ColorOutput "EN: $enFile" "Green"
Write-ColorOutput "ZH: $zhFile" "Green"

if ($Deploy) {
    Write-ColorOutput "`n[Step 8] Deploying to git..." "Magenta"
    Push-Location $WorkspaceRoot
    git add public/en/daily-commentary.html $zhFile
    git commit -m "chore: update daily commentary with SEO optimization"
    git push
    Pop-Location
    Write-ColorOutput "Deployed!" "Green"
}

exit 0


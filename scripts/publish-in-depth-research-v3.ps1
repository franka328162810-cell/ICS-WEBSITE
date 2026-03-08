param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]$ContentFile,
    
    [Parameter(Mandatory=$false)]
    [switch]$Deploy,
    
    [Parameter(Mandatory=$false)]
    [string]$WorkspaceRoot = (Get-Location).Path
)

# Color output helper
function Write-ColorOutput {
    param(
        [string]$Text,
        [string]$ForegroundColor = "White"
    )
    Write-Host $Text -ForegroundColor $ForegroundColor
}

# Validate JSON input file
if (!(Test-Path $ContentFile)) {
    Write-ColorOutput "鉂?Error: Content file '$ContentFile' not found" "Red"
    exit 1
}

Write-ColorOutput "馃摎 Publishing In-Depth Research v3 (with Auto-Archive)" "Cyan"
Write-ColorOutput "鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣" "DarkGray"

# Load JSON content
try {
    $contentData = Get-Content -Raw -Path $ContentFile | ConvertFrom-Json
    Write-ColorOutput "鉁?JSON loaded successfully" "Green"
} catch {
    Write-ColorOutput "鉂?Failed to parse JSON: $_" "Red"
    exit 1
}

# Extract week for archiving
$publicationWeek = $contentData.en.publicationWeek
if (!$publicationWeek) {
    Write-ColorOutput "鉂?Error: 'en.publicationWeek' field not found in JSON" "Red"
    exit 1
}

# Function to replace content by pattern
function Replace-ByPattern {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$NewValue
    )
    
    try {
        # Escape special regex characters in pattern
        $safeName = [regex]::Escape($Pattern)
        # match any HTML tag with data-field attribute
        $regex = "(?<pre><(?<tag>[^ >]+)[^>]*data-field=\"$safeName\"[^>]*>)(.*?)(?<post></\k<tag>>)"
        $result = $Text -replace $regex, "`${pre}$([regex]::Replace($NewValue, '&', '&amp;') -replace '"', '""')`${post}"
        return $result
    } catch {
        Write-ColorOutput "  鈿?Warning: Failed to replace pattern '$Pattern': $_" "Yellow"
        return $Text
    }
}

# Function to replace multi-line content
function Replace-ByPatternMultiLine {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$NewValue
    )
    
    try {
        $safeName = [regex]::Escape($Pattern)
        # For multi-line content, match any tag and include newlines
        $regex = "(?<pre><(?<tag>[^ >]+)[^>]*data-field=\"$safeName\"[^>]*>)([\s\S]*?)(?<post></\k<tag>>)"
        $result = $Text -replace $regex, "`${pre}$($NewValue -replace '"', '""')`${post}"
        return $result
    } catch {
        Write-ColorOutput "  鈿?Warning: Failed to replace multi-line pattern '$Pattern': $_" "Yellow"
        return $Text
    }
}

# Function to format array as list
function Join-List {
    param(
        [object]$ListArray,
        [string]$ItemTag = "li"
    )
    
    if (!$ListArray) { return "" }
    
    $items = @()
    foreach ($item in $ListArray) {
        $items += "<$ItemTag>$item</$ItemTag>"
    }
    return $items -join "`n"
}

# Function to update homepage card
function Update-HomepageCard {
    param(
        [string]$HomepageFile,
        [string]$NewTitle,
        [string]$CardType
    )

    if (!(Test-Path $HomepageFile)) {
        Write-ColorOutput "  鈿?Homepage not found: $HomepageFile" "Yellow"
        return
    }

    $content = Get-Content -Raw -Path $HomepageFile -Encoding UTF8
    $safeType = [regex]::Escape($CardType)
    $pattern = '(<span class="card-tag">' + $safeType + '</span>\s*<h3 class="card-title">)([^<]*)(</h3>)'
    $content = $content -replace $pattern, "`${1}$NewTitle`${3}"
    Set-Content -Path $HomepageFile -Value $content -Encoding UTF8 -NoNewline
}

function Convert-ToIsoDate {
    param([string]$InputDate)
    if ([string]::IsNullOrWhiteSpace($InputDate)) { return (Get-Date).ToString("yyyy-MM-dd") }
    if ($InputDate -match '^\d{4}-\d{2}-\d{2}$') { return $InputDate }
    if ($InputDate -match '^(\d{4})骞?\d{1,2})鏈?\d{1,2})鏃?') {
        return "{0}-{1:D2}-{2:D2}" -f [int]$matches[1], [int]$matches[2], [int]$matches[3]
    }
    try { return (Get-Date $InputDate).ToString("yyyy-MM-dd") } catch { return (Get-Date).ToString("yyyy-MM-dd") }
}

function Get-ResearchSeoBlock {
    param(
        [string]$Title,
        [string]$Author,
        [string]$Description,
        [string]$Section,
        [string]$PublishedDate,
        [string]$Url,
        [string]$BodyText
    )

    $desc = if ($Description.Length -gt 160) { $Description.Substring(0, 160) + "..." } else { $Description }
    $wordCount = ([regex]::Matches("$Title $Description $BodyText", '\S+')).Count
    $titleEsc = [System.Net.WebUtility]::HtmlEncode($Title)
    $descEsc = [System.Net.WebUtility]::HtmlEncode($desc)
    $authorEsc = [System.Net.WebUtility]::HtmlEncode($Author)
    $sectionEsc = [System.Net.WebUtility]::HtmlEncode($Section)

    $jsonLd = '{"@context":"https://schema.org","@type":"ScholarlyArticle","headline":"' + $titleEsc + '","author":{"@type":"Person","name":"' + $authorEsc + '"},"datePublished":"' + $PublishedDate + '","publisher":{"@type":"Organization","name":"Interstellar Civilization Studies","logo":{"@type":"ImageObject","url":"https://ics-studies.org/images/logo/ics-logo.png"}},"description":"' + $descEsc + '","articleSection":"' + $sectionEsc + '","wordCount":"' + $wordCount + '","mainEntityOfPage":"' + $Url + '"}'

    $template = @'
<!-- ICS-SEO-START (AUTO, DO NOT EDIT) -->
<meta name="description" content="{0}">
<meta property="og:type" content="article">
<meta property="og:title" content="{1}">
<meta property="og:description" content="{0}">
<meta property="og:url" content="{2}">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{1}">
<meta name="twitter:description" content="{0}">
<script type="application/ld+json">{3}</script>
<!-- ICS-SEO-END -->
'@
    return [string]::Format($template, $descEsc, $titleEsc, $Url, $jsonLd)
}

function Ensure-SeoBlock {
    param(
        [string]$Html,
        [string]$SeoBlock
    )

    $result = $Html
    if ($result -match '<!-- ICS-SEO-START \(AUTO, DO NOT EDIT\) -->.*?<!-- ICS-SEO-END -->') {
        $result = [regex]::Replace($result, '<!-- ICS-SEO-START \(AUTO, DO NOT EDIT\) -->.*?<!-- ICS-SEO-END -->', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $SeoBlock }, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    } elseif ($result -match '</head>') {
        $result = $result -replace '</head>', ($SeoBlock + "`r`n</head>")
    } else {
        throw "Mandatory SEO injection failed: </head> not found"
    }

    if (!($result -match 'application/ld\+json') -or !($result -match 'ICS-SEO-START')) {
        throw "Mandatory SEO validation failed: required SEO block missing"
    }
    return $result
}

# Function to archive previous research
function Archive-PreviousResearch {
    param(
        [string]$EnFilePath,
        [string]$ZhFilePath,
        [string]$EnArchiveDir,
        [string]$ZhArchiveDir,
        [string]$WeekIdentifier
    )
    
    # Create safe filename from week identifier
    $safeWeek = $WeekIdentifier -replace '[^\w\-]', '_'
    $enArchiveFile = Join-Path $EnArchiveDir "research-$safeWeek-en.html"
    $zhArchiveFile = Join-Path $ZhArchiveDir "research-$safeWeek-zh.html"
    
    if (Test-Path $EnFilePath) {
        $enContent = Get-Content -Raw -Path $EnFilePath
        if ($enContent.Length -gt 100) {
            Set-Content -Path $enArchiveFile -Value $enContent -Encoding UTF8 -NoNewline
            Write-ColorOutput "  鉁?English archive saved: $(Split-Path $enArchiveFile -Leaf)" "Green"
        }
    }
    
    if (Test-Path $ZhFilePath) {
        $zhContent = Get-Content -Raw -Path $ZhFilePath
        if ($zhContent.Length -gt 100) {
            Set-Content -Path $zhArchiveFile -Value $zhContent -Encoding UTF8 -NoNewline
            Write-ColorOutput "  鉁?Chinese archive saved: $(Split-Path $zhArchiveFile -Leaf)" "Green"
        }
    }
}

# Function to update archive index
function Update-ResearchArchiveIndex {
    param(
        [string]$ArchiveDir,
        [string]$Language
    )
    
    if (!(Test-Path $ArchiveDir)) {
        Write-ColorOutput "  鈿?Archive directory not found: $ArchiveDir" "Yellow"
        return $null
    }
    
    # Get all archived files sorted by name (reverse chronological)
    $archives = Get-ChildItem -Path $ArchiveDir -Filter "research-*.html" | 
        Sort-Object Name -Descending
    
    $archiveItems = @()
    
    foreach ($archive in $archives) {
        # Extract week info from filename
        if ($archive.Name -match 'research-(.+?)-(en|zh)\.html') {
            $weekInfo = $matches[1]
            $lang = $matches[2]
            
            # Only include current language
            if (($Language -eq "en" -and $lang -eq "en") -or ($Language -eq "zh" -and $lang -eq "zh")) {
                # Extract title from HTML file
                $fileContent = Get-Content -Raw -Path $archive.FullName -Encoding UTF8
                $title = ""
                
                if ($fileContent -match '<h1[^>]*>([^<]+)</h1>') {
                    $title = $matches[1]
                } elseif ($fileContent -match '<h2[^>]*>([^<]+)</h2>') {
                    $title = $matches[1]
                }
                
                if (!$title) {
                    $title = if ($Language -eq "zh") { "锛堟棤鏍囬锛? } else { "(Untitled)" }
                }
                
                $archiveItems += [PSCustomObject]@{
                    WeekInfo = $weekInfo
                    Title = $title
                    FileName = $archive.Name
                    FilePath = "articles/$($archive.Name)"
                }
            }
        }
    }
    
    return $archiveItems
}

# Main workflow
try {
    $enFile = Join-Path $WorkspaceRoot "public/en/in-depth-research.html"
    $zhFile = Join-Path $WorkspaceRoot "public/zh/娣卞害鐮旂┒.html"
    $enArchiveDir = Join-Path $WorkspaceRoot "public/en/articles"
    $zhArchiveDir = Join-Path $WorkspaceRoot "public/zh/articles"
    
    # Create archive directories if needed
    if (!(Test-Path $enArchiveDir)) { New-Item -ItemType Directory -Path $enArchiveDir -Force | Out-Null }
    if (!(Test-Path $zhArchiveDir)) { New-Item -ItemType Directory -Path $zhArchiveDir -Force | Out-Null }
    
    # Step 1: Archive previous research
    Write-ColorOutput "`n[Step 1/4] 馃摝 Archiving previous research..." "Magenta"
    Archive-PreviousResearch -EnFilePath $enFile -ZhFilePath $zhFile `
        -EnArchiveDir $enArchiveDir -ZhArchiveDir $zhArchiveDir `
        -WeekIdentifier $publicationWeek
    
    # Step 2: Load templates
    Write-ColorOutput "`n[Step 2/4] 馃搫 Loading templates..." "Magenta"
    $enTemplate = Get-Content -Raw -Path $enFile -Encoding UTF8
    $zhTemplate = Get-Content -Raw -Path $zhFile -Encoding UTF8
    
    Write-ColorOutput "  鉁?Templates loaded" "Green"
    
    # Step 3: Update content fields
    Write-ColorOutput "`n[Step 3/4] 鉁忥笍  Updating content fields..." "Magenta"
    
    # English content
    $enUpdated = $enTemplate
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "publicationWeek" -NewValue $contentData.en.publicationWeek
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "title" -NewValue $contentData.en.title
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "author" -NewValue $contentData.en.author
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "abstract" -NewValue $contentData.en.abstract
    $enUpdated = Replace-ByPatternMultiLine -Text $enUpdated -Pattern "keywords" -NewValue (Join-List -ListArray $contentData.en.keywords -ItemTag "span")
    
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "mainSection1Title" -NewValue $contentData.en.mainSection1Title
    $enUpdated = Replace-ByPatternMultiLine -Text $enUpdated -Pattern "mainSection1Content" -NewValue $contentData.en.mainSection1Content
    
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "mainSection2Title" -NewValue $contentData.en.mainSection2Title
    $enUpdated = Replace-ByPatternMultiLine -Text $enUpdated -Pattern "mainSection2Content" -NewValue $contentData.en.mainSection2Content
    
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "mainSection3Title" -NewValue $contentData.en.mainSection3Title
    $enUpdated = Replace-ByPatternMultiLine -Text $enUpdated -Pattern "mainSection3Content" -NewValue $contentData.en.mainSection3Content
    
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "conclusionTitle" -NewValue $contentData.en.conclusionTitle
    $enUpdated = Replace-ByPatternMultiLine -Text $enUpdated -Pattern "conclusionContent" -NewValue $contentData.en.conclusionContent
    
    $enUpdated = Replace-ByPatternMultiLine -Text $enUpdated -Pattern "recommendations" -NewValue (Join-List -ListArray $contentData.en.recommendations)
    $enUpdated = Replace-ByPatternMultiLine -Text $enUpdated -Pattern "relatedTopics" -NewValue (Join-List -ListArray $contentData.en.relatedTopics -ItemTag "span")
    
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "citationKey" -NewValue $contentData.en.citationKey
    $enUpdated = Replace-ByPatternMultiLine -Text $enUpdated -Pattern "acknowledgments" -NewValue $contentData.en.acknowledgments
    
    # Chinese content
    $zhUpdated = $zhTemplate
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "publicationWeek" -NewValue $contentData.zh.publicationWeek
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "title" -NewValue $contentData.zh.title
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "author" -NewValue $contentData.zh.author
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "abstract" -NewValue $contentData.zh.abstract
    $zhUpdated = Replace-ByPatternMultiLine -Text $zhUpdated -Pattern "keywords" -NewValue (Join-List -ListArray $contentData.zh.keywords -ItemTag "span")
    
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "mainSection1Title" -NewValue $contentData.zh.mainSection1Title
    $zhUpdated = Replace-ByPatternMultiLine -Text $zhUpdated -Pattern "mainSection1Content" -NewValue $contentData.zh.mainSection1Content
    
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "mainSection2Title" -NewValue $contentData.zh.mainSection2Title
    $zhUpdated = Replace-ByPatternMultiLine -Text $zhUpdated -Pattern "mainSection2Content" -NewValue $contentData.zh.mainSection2Content
    
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "mainSection3Title" -NewValue $contentData.zh.mainSection3Title
    $zhUpdated = Replace-ByPatternMultiLine -Text $zhUpdated -Pattern "mainSection3Content" -NewValue $contentData.zh.mainSection3Content
    
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "conclusionTitle" -NewValue $contentData.zh.conclusionTitle
    $zhUpdated = Replace-ByPatternMultiLine -Text $zhUpdated -Pattern "conclusionContent" -NewValue $contentData.zh.conclusionContent
    
    $zhUpdated = Replace-ByPatternMultiLine -Text $zhUpdated -Pattern "recommendations" -NewValue (Join-List -ListArray $contentData.zh.recommendations)
    $zhUpdated = Replace-ByPatternMultiLine -Text $zhUpdated -Pattern "relatedTopics" -NewValue (Join-List -ListArray $contentData.zh.relatedTopics -ItemTag "span")
    
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "citationKey" -NewValue $contentData.zh.citationKey
    $zhUpdated = Replace-ByPatternMultiLine -Text $zhUpdated -Pattern "acknowledgments" -NewValue $contentData.zh.acknowledgments
    
    Write-ColorOutput "  鉁?All fields updated (EN + ZH)" "Green"
    
    # Step 4: Enforce SEO block (mandatory)
    Write-ColorOutput "`n[Step 4/6] 馃敀 Enforcing mandatory SEO block..." "Magenta"
    $isoDate = Convert-ToIsoDate -InputDate (Get-Date -Format "yyyy-MM-dd")
    $enBody = "$($contentData.en.mainSection1Content) $($contentData.en.mainSection2Content) $($contentData.en.mainSection3Content) $($contentData.en.conclusionContent)"
    $zhBody = "$($contentData.zh.mainSection1Content) $($contentData.zh.mainSection2Content) $($contentData.zh.mainSection3Content) $($contentData.zh.conclusionContent)"
    $enSeo = Get-ResearchSeoBlock -Title $contentData.en.title -Author $contentData.en.author -Description $contentData.en.abstract -Section "In-Depth Research" -PublishedDate $isoDate -Url "https://ics-studies.org/en/in-depth-research.html" -BodyText $enBody
    $zhSeo = Get-ResearchSeoBlock -Title $contentData.zh.title -Author $contentData.zh.author -Description $contentData.zh.abstract -Section "In-Depth Research" -PublishedDate $isoDate -Url "https://ics-studies.org/zh/%E6%B7%B1%E5%BA%A6%E7%A0%94%E7%A9%B6.html" -BodyText $zhBody
    $enUpdated = Ensure-SeoBlock -Html $enUpdated -SeoBlock $enSeo
    $zhUpdated = Ensure-SeoBlock -Html $zhUpdated -SeoBlock $zhSeo
    Write-ColorOutput "  鉁?Mandatory SEO block enforced (EN + ZH)" "Green"

    # Step 5: Write updated files
    Write-ColorOutput "`n[Step 5/6] 馃捑 Writing updated pages..." "Magenta"
    Set-Content -Path $enFile -Value $enUpdated -Encoding UTF8 -NoNewline
    Set-Content -Path $zhFile -Value $zhUpdated -Encoding UTF8 -NoNewline
    
    Write-ColorOutput "  鉁?English page updated" "Green"
    Write-ColorOutput "  鉁?Chinese page updated" "Green"
    
    # Step 6: Update homepage cards
    Write-ColorOutput "`n[Step 6/6] 馃彔 Updating homepage cards..." "Magenta"
    $homepageEn = Join-Path $WorkspaceRoot "public/index.html"
    $homepageZh = Join-Path $WorkspaceRoot "public/zh/棣栭〉.html"
    
    Update-HomepageCard -HomepageFile $homepageEn -NewTitle $contentData.en.title -CardType "Research"
    Update-HomepageCard -HomepageFile $homepageZh -NewTitle $contentData.zh.title -CardType "鐮旂┒"
    
    Write-ColorOutput "  鉁?Homepage cards synchronized" "Green"
    
    # Optional: Deploy
    if ($Deploy) {
        Write-ColorOutput "`n[Bonus] 馃殌 Deploying to git..." "Magenta"
        
        $gitDir = $WorkspaceRoot
        if (Test-Path "$gitDir/.git") {
            Push-Location $gitDir
            
            # Stage changes
            git add public/en/in-depth-research.html public/zh/娣卞害鐮旂┒.html public/en/articles/ public/zh/articles/ public/index.html public/zh/棣栭〉.html
            
            # Commit
            $commitMsg = "馃摎 In-Depth Research - $publicationWeek"
            git commit -m $commitMsg
            
            # Push
            git push
            
            Write-ColorOutput "  鉁?Git commit: $commitMsg" "Green"
            Write-ColorOutput "  鉁?Pushed to remote" "Green"
            
            Pop-Location
        } else {
            Write-ColorOutput "  鈿?Not a git repository" "Yellow"
        }
    }
    
    Write-ColorOutput "`n鉁?Publishing complete!" "Green"
    Write-ColorOutput "鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣" "DarkGray"
    Write-ColorOutput "Publication Week: $publicationWeek" "Cyan"
    Write-ColorOutput "EN: $enFile" "Cyan"
    Write-ColorOutput "ZH: $zhFile" "Cyan"
    if ($Deploy) {
        Write-ColorOutput "Status: 鉁?Deployed" "Green"
    } else {
        Write-ColorOutput "Status: 鈿狅笍  Not deployed (use -Deploy flag to publish)" "Yellow"
    }
    
} catch {
    Write-ColorOutput "鉂?Error during publishing: $_" "Red"
    exit 1
}


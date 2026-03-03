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
        # Main workflow
        try {
            $enFile = Join-Path $WorkspaceRoot "public/en/daily-commentary.html"
            $zhFile = Resolve-ZhPageByMarker -Root $WorkspaceRoot -Marker 'data-page="news-daily"'
            $homepageEn = Join-Path $WorkspaceRoot "public/index.html"
            $homepageZh = Resolve-ZhPageByMarker -Root $WorkspaceRoot -Marker 'data-page="home"'
            $enArchiveDir = Join-Path $WorkspaceRoot "public/en/news"
            $zhArchiveDir = Join-Path $WorkspaceRoot "public/zh/news"

            if (!(Test-Path $enArchiveDir)) { New-Item -ItemType Directory -Path $enArchiveDir -Force | Out-Null }
            if (!(Test-Path $zhArchiveDir)) { New-Item -ItemType Directory -Path $zhArchiveDir -Force | Out-Null }

            Write-ColorOutput "`n[Step 1/6] Archiving previous commentary..." "Magenta"
            Archive-PreviousCommentary -EnFilePath $enFile -ZhFilePath $zhFile -EnArchiveDir $enArchiveDir -ZhArchiveDir $zhArchiveDir

            Write-ColorOutput "`n[Step 2/6] Loading templates..." "Magenta"
            $enTemplate = Get-Content -Raw -Path $enFile -Encoding UTF8
            $zhTemplate = Get-Content -Raw -Path $zhFile -Encoding UTF8

            Write-ColorOutput "`n[Step 3/6] Updating content fields..." "Magenta"
            $enUpdated = $enTemplate
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "date" -NewValue $contentData.en.date
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "category" -NewValue $contentData.en.category
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "headline" -NewValue $contentData.en.headline
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "source" -NewValue $contentData.en.source
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "sourceTime" -NewValue $contentData.en.sourceTime
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "summary" -NewValue $contentData.en.summary
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "newThreeViews" -NewValue $contentData.en.newThreeViews
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "normative" -NewValue $contentData.en.normative
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "longTermImpact" -NewValue $contentData.en.longTermImpact
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "reflectionQ1" -NewValue $contentData.en.reflectionQ1
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "reflectionQ2" -NewValue $contentData.en.reflectionQ2
            $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "tags" -NewValue (Join-Tags -TagArray $contentData.en.tags)

            $zhUpdated = $zhTemplate
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "date" -NewValue $contentData.zh.date
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "category" -NewValue $contentData.zh.category
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "headline" -NewValue $contentData.zh.headline
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "source" -NewValue $contentData.zh.source
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "sourceTime" -NewValue $contentData.zh.sourceTime
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "summary" -NewValue $contentData.zh.summary
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "newThreeViews" -NewValue $contentData.zh.newThreeViews
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "normative" -NewValue $contentData.zh.normative
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "longTermImpact" -NewValue $contentData.zh.longTermImpact
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "reflectionQ1" -NewValue $contentData.zh.reflectionQ1
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "reflectionQ2" -NewValue $contentData.zh.reflectionQ2
            $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "tags" -NewValue (Join-Tags -TagArray $contentData.zh.tags)

            Write-ColorOutput "`n[Step 4/6] Enforcing mandatory SEO block..." "Magenta"
            $isoDate = Convert-ToIsoDate -InputDate $contentData.en.date
            $enSeo = Get-DailySeoBlock -Headline $contentData.en.headline -Category $contentData.en.category -Summary $contentData.en.summary -Author "ICS Editorial Team" -PublishedDate $isoDate -Url "https://ics-studies.org/en/daily-commentary.html"
            $zhSeo = Get-DailySeoBlock -Headline $contentData.zh.headline -Category $contentData.zh.category -Summary $contentData.zh.summary -Author "ICS Editorial Team" -PublishedDate $isoDate -Url "https://ics-studies.org/zh/%E6%AF%8F%E6%97%A5%E7%83%AD%E7%82%B9%E8%AF%84%E8%AE%BA.html"
            $enUpdated = Ensure-SeoBlock -Html $enUpdated -SeoBlock $enSeo
            $zhUpdated = Ensure-SeoBlock -Html $zhUpdated -SeoBlock $zhSeo

            Write-ColorOutput "`n[Step 5/6] Writing updated pages..." "Magenta"
            Set-Content -Path $enFile -Value $enUpdated -Encoding UTF8 -NoNewline
            Set-Content -Path $zhFile -Value $zhUpdated -Encoding UTF8 -NoNewline

            Write-ColorOutput "`n[Step 6/6] Syncing homepage cards..." "Magenta"
            Update-HomepageCard -HomepageFile $homepageEn -NewTitle $contentData.en.headline -CardType "Commentary"

            # For zh homepage, update the first card title by position to avoid locale coupling
            $zhHome = Get-Content -Raw -Path $homepageZh -Encoding UTF8
            $i = 0
            $zhHome = [regex]::Replace($zhHome, '(<h3 class="card-title">)([^<]*)(</h3>)', [System.Text.RegularExpressions.MatchEvaluator]{
                param($m)
                $script:i++
                if ($script:i -eq 1) { return $m.Groups[1].Value + $contentData.zh.headline + $m.Groups[3].Value }
                return $m.Value
            })
            Set-Content -Path $homepageZh -Value $zhHome -Encoding UTF8 -NoNewline

            if ($Deploy) {
                Write-ColorOutput "`n[Bonus] Deploying to git..." "Magenta"
                if (Test-Path (Join-Path $WorkspaceRoot ".git")) {
                    Push-Location $WorkspaceRoot
                    git add $enFile $zhFile public/en/news/ public/zh/news/ $homepageEn $homepageZh
                    $commitMsg = "Daily commentary - $publishDate"
                    git commit -m $commitMsg
                    git push
                    Pop-Location
                }
            }

            Write-ColorOutput "`nPublishing complete." "Green"
        } catch {
            Write-ColorOutput "Error during publishing: $_" "Red"
            exit 1
        }
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

# Function to archive previous commentary
function Archive-PreviousCommentary {
    param(
        [string]$EnFilePath,
        [string]$ZhFilePath,
        [string]$EnArchiveDir,
        [string]$ZhArchiveDir
    )
    
    $enArchiveFile = Join-Path $EnArchiveDir "news-daily-$(Get-Date -Format 'yyyyMMdd').html"
    $zhArchiveFile = Join-Path $ZhArchiveDir "news-daily-$(Get-Date -Format 'yyyyMMdd').html"
    
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

# Function to update archive index with dynamic content
function Update-ArchiveIndex {
    param(
        [string]$ArchiveDir,
        [string]$Language,
        [string]$CurrentDate
    )
    
    if (!(Test-Path $ArchiveDir)) {
        Write-ColorOutput "  鈿?Archive directory not found: $ArchiveDir" "Yellow"
        return $null
    }
    
    # Get all archived files sorted by date (newest first)
    $archives = Get-ChildItem -Path $ArchiveDir -Filter "news-daily-*.html" | 
        Sort-Object Name -Descending
    
    $archiveItems = @()
    
    foreach ($archive in $archives) {
        # Extract date from filename (news-daily-20250304.html -> 20250304)
        if ($archive.Name -match 'news-daily-(\d{8})\.html') {
            $dateStr = $matches[1]
            
            # Parse date
            $year = $dateStr.Substring(0, 4)
            $month = $dateStr.Substring(4, 2)
            $day = $dateStr.Substring(6, 2)
            
            # Format date based on language
            if ($Language -eq "zh") {
                $displayDate = "${year}骞?{month}鏈?{day}鏃?
            } else {
                $displayDate = (Get-Date -Date "$year-$month-$day" -Format "MMMM d, yyyy").ToUpper()
            }
            
            # Extract headline from HTML file
            $fileContent = Get-Content -Raw -Path $archive.FullName -Encoding UTF8
            $headline = ""
            
            if ($fileContent -match '<h2[^>]*>([^<]+)</h2>') {
                $headline = $matches[1]
            } elseif ($fileContent -match '<h1[^>]*>([^<]+)</h1>') {
                $headline = $matches[1]
            }
            
            if (!$headline) {
                $headline = "(Untitled)"
            }
            
            $archiveItems += [PSCustomObject]@{
                Date = $displayDate
                Headline = $headline
                FileName = $archive.Name
                FilePath = "news/$($archive.Name)"
            }
        }
    }
    
    return $archiveItems
}

# Main workflow
try {
    $enFile = Join-Path $WorkspaceRoot "public/en/daily-commentary.html"
    $zhFile = Join-Path $WorkspaceRoot "public/zh/姣忔棩鐑偣璇勮.html"
        $zhFile = Resolve-ZhPageByMarker -Root $WorkspaceRoot -Marker 'data-page="news-daily"'
        $homepageZh = Resolve-ZhPageByMarker -Root $WorkspaceRoot -Marker 'data-page="home"'
    $enArchiveDir = Join-Path $WorkspaceRoot "public/en/news"
    $zhArchiveDir = Join-Path $WorkspaceRoot "public/zh/news"
    
    # Create archive directories if needed
    if (!(Test-Path $enArchiveDir)) { New-Item -ItemType Directory -Path $enArchiveDir -Force | Out-Null }
    if (!(Test-Path $zhArchiveDir)) { New-Item -ItemType Directory -Path $zhArchiveDir -Force | Out-Null }
    
    # Step 1: Archive previous commentary
    Write-ColorOutput "`n[Step 1/4] 馃摝 Archiving previous commentary..." "Magenta"
    Archive-PreviousCommentary -EnFilePath $enFile -ZhFilePath $zhFile `
        -EnArchiveDir $enArchiveDir -ZhArchiveDir $zhArchiveDir
    
    # Step 2: Load templates
    Write-ColorOutput "`n[Step 2/4] 馃搫 Loading templates..." "Magenta"
    $enTemplate = Get-Content -Raw -Path $enFile -Encoding UTF8
    $zhTemplate = Get-Content -Raw -Path $zhFile -Encoding UTF8
    
    Write-ColorOutput "  鉁?Templates loaded" "Green"
    
    # Step 3: Update content fields
    Write-ColorOutput "`n[Step 3/4] 鉁忥笍  Updating content fields..." "Magenta"
    
    # English content
    $enUpdated = $enTemplate
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "date" -NewValue $contentData.en.date
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "category" -NewValue $contentData.en.category
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "headline" -NewValue $contentData.en.headline
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "source" -NewValue $contentData.en.source
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "sourceTime" -NewValue $contentData.en.sourceTime
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "summary" -NewValue $contentData.en.summary
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "newThreeViews" -NewValue $contentData.en.newThreeViews
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "normative" -NewValue $contentData.en.normative
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "longTermImpact" -NewValue $contentData.en.longTermImpact
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "reflectionQ1" -NewValue $contentData.en.reflectionQ1
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "reflectionQ2" -NewValue $contentData.en.reflectionQ2
    $tags = Join-Tags -TagArray $contentData.en.tags
    $enUpdated = Replace-ByPattern -Text $enUpdated -Pattern "tags" -NewValue $tags
    
    # Chinese content
    $zhUpdated = $zhTemplate
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "date" -NewValue $contentData.zh.date
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "category" -NewValue $contentData.zh.category
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "headline" -NewValue $contentData.zh.headline
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "source" -NewValue $contentData.zh.source
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "sourceTime" -NewValue $contentData.zh.sourceTime
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "summary" -NewValue $contentData.zh.summary
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "newThreeViews" -NewValue $contentData.zh.newThreeViews
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "normative" -NewValue $contentData.zh.normative
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "longTermImpact" -NewValue $contentData.zh.longTermImpact
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "reflectionQ1" -NewValue $contentData.zh.reflectionQ1
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "reflectionQ2" -NewValue $contentData.zh.reflectionQ2
    $tags = Join-Tags -TagArray $contentData.zh.tags
    $zhUpdated = Replace-ByPattern -Text $zhUpdated -Pattern "tags" -NewValue $tags
    
    Write-ColorOutput "  鉁?All 12 fields updated (EN + ZH)" "Green"
    
    # Step 4: Enforce SEO block (mandatory)
    Write-ColorOutput "`n[Step 4/6] 馃敀 Enforcing mandatory SEO block..." "Magenta"
    $isoDate = Convert-ToIsoDate -InputDate $contentData.en.date
    $enSeo = Get-DailySeoBlock -Headline $contentData.en.headline -Category $contentData.en.category -Summary $contentData.en.summary -Author "ICS Editorial Team" -PublishedDate $isoDate -Url "https://ics-studies.org/en/daily-commentary.html"
    $zhSeo = Get-DailySeoBlock -Headline $contentData.zh.headline -Category $contentData.zh.category -Summary $contentData.zh.summary -Author "ICS Editorial Team" -PublishedDate $isoDate -Url "https://ics-studies.org/zh/%E6%AF%8F%E6%97%A5%E7%83%AD%E7%82%B9%E8%AF%84%E8%AE%BA.html"
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
    
    Update-HomepageCard -HomepageFile $homepageEn -NewTitle $contentData.en.headline -CardType "Commentary"
    Update-HomepageCard -HomepageFile $homepageZh -NewTitle $contentData.zh.headline -CardType "璇勮"
    
    Write-ColorOutput "  鉁?Homepage cards synchronized" "Green"
    
    # Optional: Deploy
    if ($Deploy) {
        Write-ColorOutput "`n[Bonus] 馃殌 Deploying to git..." "Magenta"
        
        $gitDir = $WorkspaceRoot
        if (Test-Path "$gitDir/.git") {
            Push-Location $gitDir
            
            # Stage changes
            git add public/en/daily-commentary.html public/zh/姣忔棩鐑偣璇勮.html public/en/news/ public/zh/news/ public/index.html public/zh/棣栭〉.html
                        git add $enFile $zhFile public/en/news/ public/zh/news/ $homepageEn $homepageZh
            
            # Commit
            $commitMsg = "馃摪 Daily commentary - $publishDate"
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
    Write-ColorOutput "鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹? "DarkGray"
    Write-ColorOutput "Date: $publishDate" "Cyan"
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


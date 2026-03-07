param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]$ContentFile,
    
    [Parameter(Mandatory=$false)]
    [switch]$Deploy,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoTranslate,
    
    [Parameter(Mandatory=$false)]
    [string]$OpenAIKey = $env:OPENAI_API_KEY,
    
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

# Function to translate Chinese to English using OpenAI
function Translate-ToEnglish {
    param(
        [string]$ChineseText,
        [string]$FieldName,
        [string]$ApiKey
    )
    
    if (!$ApiKey) {
        Write-ColorOutput "  ⚠ No OpenAI API key found. Skipping translation for '$FieldName'" "Yellow"
        return $ChineseText
    }
    
    $headers = @{
        "Authorization" = "Bearer $ApiKey"
        "Content-Type" = "application/json"
    }
    
    # Tailored prompts for different field types
    $systemPrompt = switch ($FieldName) {
        "headline" { "You are a professional news translator. Translate the following Chinese news headline to English. Keep it concise and impactful." }
        "summary" { "You are a professional news translator. Translate the following Chinese news summary to English. Maintain journalistic tone." }
        "tags" { "Translate these Chinese tags to English. Return only comma-separated English terms." }
        default { "You are a professional translator specializing in academic and policy content. Translate the following Chinese text to natural, fluent English." }
    }
    
    $body = @{
        model = "gpt-4o-mini"
        messages = @(
            @{
                role = "system"
                content = $systemPrompt
            },
            @{
                role = "user"
                content = $ChineseText
            }
        )
        temperature = 0.3
        max_tokens = 2000
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" -Method Post -Headers $headers -Body $body
        $translation = $response.choices[0].message.content.Trim()
        Write-ColorOutput "    ✓ Translated: $FieldName" "Green"
        return $translation
    } catch {
        Write-ColorOutput "    ✗ Translation failed for '$FieldName': $_" "Red"
        return $ChineseText
    }
}

# Validate JSON input file
if (!(Test-Path $ContentFile)) {
    Write-ColorOutput "❌ Error: Content file '$ContentFile' not found" "Red"
    exit 1
}

Write-ColorOutput "📖 Publishing Daily Commentary v3 (Auto-Translate Edition)" "Cyan"
Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "DarkGray"

# Load JSON content
try {
    $contentData = Get-Content -Raw -Path $ContentFile | ConvertFrom-Json
    Write-ColorOutput "✓ JSON loaded successfully" "Green"
} catch {
    Write-ColorOutput "❌ Failed to parse JSON: $_" "Red"
    exit 1
}

# Auto-translate if needed
if ($AutoTranslate -and $contentData.zh) {
    Write-ColorOutput "`n[Auto-Translate] 🌐 Translating Chinese to English..." "Magenta"
    
    if (!$contentData.en) {
        $contentData | Add-Member -NotePropertyName "en" -NotePropertyValue @{} -Force
    }
    
    # Translate all fields
    $contentData.en.date = $contentData.zh.date
    $contentData.en.category = Translate-ToEnglish -ChineseText $contentData.zh.category -FieldName "category" -ApiKey $OpenAIKey
    $contentData.en.headline = Translate-ToEnglish -ChineseText $contentData.zh.headline -FieldName "headline" -ApiKey $OpenAIKey
    $contentData.en.source = $contentData.zh.source
    $contentData.en.sourceTime = $contentData.zh.sourceTime
    $contentData.en.summary = Translate-ToEnglish -ChineseText $contentData.zh.summary -FieldName "summary" -ApiKey $OpenAIKey
    $contentData.en.newThreeViews = Translate-ToEnglish -ChineseText $contentData.zh.newThreeViews -FieldName "newThreeViews" -ApiKey $OpenAIKey
    $contentData.en.normative = Translate-ToEnglish -ChineseText $contentData.zh.normative -FieldName "normative" -ApiKey $OpenAIKey
    $contentData.en.longTermImpact = Translate-ToEnglish -ChineseText $contentData.zh.longTermImpact -FieldName "longTermImpact" -ApiKey $OpenAIKey
    $contentData.en.reflectionQ1 = Translate-ToEnglish -ChineseText $contentData.zh.reflectionQ1 -FieldName "reflectionQ1" -ApiKey $OpenAIKey
    $contentData.en.reflectionQ2 = Translate-ToEnglish -ChineseText $contentData.zh.reflectionQ2 -FieldName "reflectionQ2" -ApiKey $OpenAIKey
    
    # Handle tags
    if ($contentData.zh.tags) {
        $tagsText = $contentData.zh.tags -join ", "
        $translatedTags = Translate-ToEnglish -ChineseText $tagsText -FieldName "tags" -ApiKey $OpenAIKey
        $contentData.en.tags = $translatedTags -split ",\s*"
    }
    
    Write-ColorOutput "✓ All fields translated" "Green"
}

# Extract date for archiving
$publishDate = $contentData.en.date
if (!$publishDate) {
    Write-ColorOutput "❌ Error: 'en.date' field not found in JSON" "Red"
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
        $result = $Text -replace "(?<pre><span[^>]*data-field=""$safeName""[^>]*>)(.*?)(?<post></span>)", "`${pre}$([regex]::Replace($NewValue, '&', '&amp;') -replace '"', '""')`${post}"
        return $result
    } catch {
        Write-ColorOutput "  ⚠ Warning: Failed to replace pattern '$Pattern': $_" "Yellow"
        return $Text
    }
}

# Function to format tags
function Join-Tags {
    param([object]$TagArray)
    if (!$TagArray) { return "" }
    $spans = @()
    foreach ($tag in $TagArray) {
        $spans += "<span class='news-tag'>$tag</span>"
    }
    return $spans -join ""
}

# Function to update homepage card
function Update-HomepageCard {
    param(
        [string]$HomepageFile,
        [string]$NewTitle,
        [string]$CardType
    )
    
    if (!(Test-Path $HomepageFile)) {
        Write-ColorOutput "  ⚠ Homepage not found: $HomepageFile" "Yellow"
        return
    }
    
    $content = Get-Content -Raw -Path $HomepageFile -Encoding UTF8
    
    # Use regex to find and replace card title for specific card type
    if ($CardType -eq "Commentary" -or $CardType -eq "评论") {
        # Match the first card with tag "Commentary" or "评论"
        $pattern = "(<span class=`"card-tag`">$CardType</span>\s*<h3 class=`"card-title`\">)([^<]*)(</h3>)"
        $replacement = "`${1}$NewTitle`${3}"
        $content = $content -replace $pattern, $replacement
    }
    
    Set-Content -Path $HomepageFile -Value $content -Encoding UTF8 -NoNewline
}

# Function to archive previous commentary
function Archive-PreviousCommentary {
    param(
        [string]$SourceFile,
        [string]$TargetDir,
        [string]$Date
    )
    
    if (!(Test-Path $SourceFile)) {
        Write-ColorOutput "  ⚠ Source file not found, skipping archive" "Yellow"
        return
    }
    
    if (!(Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    
    # Extract language from filename
    $lang = if ($SourceFile -match "daily-commentary\.html") { "en" } else { "zh" }
    $archiveFile = Join-Path $TargetDir "news-$Date-$lang.html"
    
    Copy-Item -Path $SourceFile -Destination $archiveFile -Force
    Write-ColorOutput "  ✓ Archived to: $archiveFile" "Green"
}

# Function to update archive index
function Update-ArchiveIndex {
    param(
        [string]$ArchiveDir,
        [string]$IndexFile,
        [string]$Language
    )
    
    if (!(Test-Path $ArchiveDir)) {
        Write-ColorOutput "  ⚠ Archive directory not found" "Yellow"
        return
    }
    
    # Scan archived files
    $archiveFiles = Get-ChildItem -Path $ArchiveDir -Filter "news-*-$Language.html" | Sort-Object Name -Descending
    
    # Build archive cards HTML
    $cardsHtml = ""
    foreach ($file in $archiveFiles) {
        if ($file.Name -match "news-(\d{4}-\d{2}-\d{2})-") {
            $date = $matches[1]
            $content = Get-Content -Raw -Path $file.FullName -Encoding UTF8
            
            # Extract headline
            if ($content -match 'data-field="headline"[^>]*>([^<]+)</span>') {
                $headline = $matches[1]
                $card = @"
                <div class="archive-card">
                    <div class="archive-date">$date</div>
                    <h3 class="archive-title"><a href="news/$($file.Name)">$headline</a></h3>
                </div>
"@
                $cardsHtml += $card
            }
        }
    }
    
    # Update index file
    if (Test-Path $IndexFile) {
        $indexContent = Get-Content -Raw -Path $IndexFile -Encoding UTF8
        $indexContent = $indexContent -replace '(?<=<div class="archive-grid">).*?(?=</div>\s*</div>\s*</section>)', "`n$cardsHtml`n            "
        Set-Content -Path $IndexFile -Value $indexContent -Encoding UTF8 -NoNewline
    }
}

# Main publishing workflow
try {
    $enFile = Join-Path $WorkspaceRoot "public/en/daily-commentary.html"
    $zhFile = Join-Path $WorkspaceRoot "public/zh/每日热点评论.html"
    
    # Step 1: Archive old content
    Write-ColorOutput "`n[Step 1/5] 📦 Archiving previous commentary..." "Magenta"
    Archive-PreviousCommentary -SourceFile $enFile -TargetDir (Join-Path $WorkspaceRoot "public/en/news") -Date $publishDate
    Archive-PreviousCommentary -SourceFile $zhFile -TargetDir (Join-Path $WorkspaceRoot "public/zh/news") -Date $publishDate
    
    # Step 2: Update archive index
    Write-ColorOutput "`n[Step 2/5] 📑 Updating archive indexes..." "Magenta"
    Update-ArchiveIndex -ArchiveDir (Join-Path $WorkspaceRoot "public/en/news") -IndexFile (Join-Path $WorkspaceRoot "public/en/news-archive.html") -Language "en"
    Update-ArchiveIndex -ArchiveDir (Join-Path $WorkspaceRoot "public/zh/news") -IndexFile (Join-Path $WorkspaceRoot "public/zh/每日热点评论归档.html") -Language "zh"
    Write-ColorOutput "  ✓ Archive indexes updated" "Green"
    
    # Step 3: Update content
    Write-ColorOutput "`n[Step 3/5] ✏️  Updating page content..." "Magenta"
    
    $enUpdated = Get-Content -Raw -Path $enFile -Encoding UTF8
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
    
    $zhUpdated = Get-Content -Raw -Path $zhFile -Encoding UTF8
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
    
    Write-ColorOutput "  ✓ All 12 fields updated (EN + ZH)" "Green"
    
    # Step 4: Write updated files
    Write-ColorOutput "`n[Step 4/5] 💾 Writing updated pages..." "Magenta"
    Set-Content -Path $enFile -Value $enUpdated -Encoding UTF8 -NoNewline
    Set-Content -Path $zhFile -Value $zhUpdated -Encoding UTF8 -NoNewline

    # create ascii alias for Chinese daily commentary page
    $zhAlias = Join-Path $WorkspaceRoot "public/zh/daily-commentary.html"
    $aliasHtml = "<!DOCTYPE html><html lang='zh-CN'><head><meta charset='UTF-8'><meta http-equiv='refresh' content='0; url=每日热点评论.html'><link rel='canonical' href='每日热点评论.html'></head><body></body></html>"
    Set-Content -Path $zhAlias -Value $aliasHtml -Encoding UTF8 -NoNewline
    Write-ColorOutput "  ✓ Alias file created" "Green"

    Write-ColorOutput "  ✓ English page updated" "Green"
    Write-ColorOutput "  ✓ Chinese page updated" "Green"
    
    # Step 5: Update homepage cards
    Write-ColorOutput "`n[Step 5/5] 🏠 Updating homepage cards..." "Magenta"
    $homepageEn = Join-Path $WorkspaceRoot "public/index.html"
    $homepageZh = Join-Path $WorkspaceRoot "public/zh/首页.html"
    
    Update-HomepageCard -HomepageFile $homepageEn -NewTitle $contentData.en.headline -CardType "Commentary"
    Update-HomepageCard -HomepageFile $homepageZh -NewTitle $contentData.zh.headline -CardType "评论"
    
    Write-ColorOutput "  ✓ Homepage cards synchronized" "Green"
    
    # Optional: Deploy
    if ($Deploy) {
        Write-ColorOutput "`n[Bonus] 🚀 Deploying to git..." "Magenta"
        
        $gitDir = $WorkspaceRoot
        if (Test-Path "$gitDir/.git") {
            Push-Location $gitDir
            
            # Stage changes
            git add public/en/daily-commentary.html public/zh/每日热点评论.html public/zh/daily-commentary.html public/en/news/ public/zh/news/ public/index.html public/zh/首页.html
            
            # Commit
            $commitMsg = "📰 Daily commentary - $publishDate"
            git commit -m $commitMsg
            
            # Push
            git push
            
            Write-ColorOutput "  ✓ Git commit: $commitMsg" "Green"
            Write-ColorOutput "  ✓ Pushed to remote" "Green"
            
            Pop-Location
        } else {
            Write-ColorOutput "  ⚠ Not a git repository" "Yellow"
        }
    }
    
    Write-ColorOutput "`n✨ Publishing complete!" "Green"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "DarkGray"
    Write-ColorOutput "Date: $publishDate" "Cyan"
    Write-ColorOutput "EN: $enFile" "Cyan"
    Write-ColorOutput "ZH: $zhFile" "Cyan"
    if ($AutoTranslate) {
        Write-ColorOutput "Translation: ✅ Auto-translated" "Green"
    }
    if ($Deploy) {
        Write-ColorOutput "Status: ✅ Deployed" "Green"
    } else {
        Write-ColorOutput "Status: ⚠️  Not deployed (use -Deploy flag to publish)" "Yellow"
    }
    
} catch {
    Write-ColorOutput "❌ Error during publishing: $_" "Red"
    exit 1
}

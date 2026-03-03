param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]$ContentFile,
    
    [Parameter(Mandatory=$false)]
    [switch]$Deploy,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoTranslate,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("zhipu", "deepseek", "moonshot", "openai", "ollama")]
    [string]$ApiProvider = "zhipu",
    
    [Parameter(Mandatory=$false)]
    [string]$ApiKey,
    
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

# Get API configuration based on provider
function Get-ApiConfig {
    param([string]$Provider)
    
    $configs = @{
        "zhipu" = @{
            Name = "智谱AI (GLM-4)"
            Endpoint = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
            Model = "glm-4-flash"
            KeyEnvVar = "ZHIPU_API_KEY"
            Format = "openai"
        }
        "deepseek" = @{
            Name = "DeepSeek"
            Endpoint = "https://api.deepseek.com/v1/chat/completions"
            Model = "deepseek-chat"
            KeyEnvVar = "DEEPSEEK_API_KEY"
            Format = "openai"
        }
        "moonshot" = @{
            Name = "Moonshot AI"
            Endpoint = "https://api.moonshot.cn/v1/chat/completions"
            Model = "moonshot-v1-8k"
            KeyEnvVar = "MOONSHOT_API_KEY"
            Format = "openai"
        }
        "openai" = @{
            Name = "OpenAI"
            Endpoint = "https://api.openai.com/v1/chat/completions"
            Model = "gpt-4o-mini"
            KeyEnvVar = "OPENAI_API_KEY"
            Format = "openai"
        }
        "ollama" = @{
            Name = "Ollama (本地)"
            Endpoint = "http://localhost:11434/api/chat"
            Model = "qwen2:7b"
            KeyEnvVar = ""
            Format = "ollama"
        }
    }
    
    return $configs[$Provider]
}

# Function to translate Chinese to English
function Translate-ToEnglish {
    param(
        [string]$ChineseText,
        [string]$FieldName,
        [hashtable]$Config,
        [string]$ApiKey
    )
    
    if ($Config.Format -eq "openai") {
        return Translate-OpenAIFormat -ChineseText $ChineseText -FieldName $FieldName -Config $Config -ApiKey $ApiKey
    } elseif ($Config.Format -eq "ollama") {
        return Translate-OllamaFormat -ChineseText $ChineseText -FieldName $FieldName -Config $Config
    }
}

# OpenAI format translation
function Translate-OpenAIFormat {
    param(
        [string]$ChineseText,
        [string]$FieldName,
        [hashtable]$Config,
        [string]$ApiKey
    )
    
    if (!$ApiKey) {
        Write-ColorOutput "  ⚠ No API key for $($Config.Name). Skipping '$FieldName'" "Yellow"
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
        model = $Config.Model
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
        $response = Invoke-RestMethod -Uri $Config.Endpoint -Method Post -Headers $headers -Body $body -ContentType "application/json; charset=utf-8"
        $translation = $response.choices[0].message.content.Trim()
        Write-ColorOutput "    ✓ $FieldName" "Green"
        return $translation
    } catch {
        Write-ColorOutput "    ✗ Failed: $FieldName ($_)" "Red"
        return $ChineseText
    }
}

# Ollama format translation
function Translate-OllamaFormat {
    param(
        [string]$ChineseText,
        [string]$FieldName,
        [hashtable]$Config
    )
    
    $systemPrompt = "You are a professional translator. Translate the following Chinese text to natural, fluent English."
    
    $body = @{
        model = $Config.Model
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
        stream = $false
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri $Config.Endpoint -Method Post -Body $body -ContentType "application/json; charset=utf-8"
        $translation = $response.message.content.Trim()
        Write-ColorOutput "    ✓ $FieldName" "Green"
        return $translation
    } catch {
        Write-ColorOutput "    ✗ Failed: $FieldName ($_)" "Red"
        return $ChineseText
    }
}

# Validate JSON input file
if (!(Test-Path $ContentFile)) {
    Write-ColorOutput "❌ Error: Content file '$ContentFile' not found" "Red"
    exit 1
}

Write-ColorOutput "📖 Publishing Daily Commentary v3 (China Edition)" "Cyan"
Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "DarkGray"

# Load JSON content
try {
    $contentData = Get-Content -Raw -Path $ContentFile -Encoding UTF8 | ConvertFrom-Json
    Write-ColorOutput "✓ JSON loaded successfully" "Green"
} catch {
    Write-ColorOutput "❌ Failed to parse JSON: $_" "Red"
    exit 1
}

# Auto-translate if needed
if ($AutoTranslate -and $contentData.zh) {
    $apiConfig = Get-ApiConfig -Provider $ApiProvider
    Write-ColorOutput "`n[Auto-Translate] 🌐 Using: $($apiConfig.Name)" "Magenta"
    
    # Get API key
    if (!$ApiKey) {
        $ApiKey = [Environment]::GetEnvironmentVariable($apiConfig.KeyEnvVar)
    }
    
    if (!$ApiKey -and $ApiProvider -ne "ollama") {
        Write-ColorOutput "❌ Error: No API key found for $($apiConfig.Name)" "Red"
        Write-ColorOutput "   Set environment variable: `$$($apiConfig.KeyEnvVar)" "Yellow"
        exit 1
    }
    
    if (!$contentData.en) {
        $contentData | Add-Member -NotePropertyName "en" -NotePropertyValue @{} -Force
    }
    
    Write-ColorOutput "  Translating 12 fields..." "Gray"
    
    # Translate all fields
    $contentData.en | Add-Member -NotePropertyName "date" -NotePropertyValue $contentData.zh.date -Force
    $contentData.en | Add-Member -NotePropertyName "category" -NotePropertyValue (Translate-ToEnglish -ChineseText $contentData.zh.category -FieldName "category" -Config $apiConfig -ApiKey $ApiKey) -Force
    $contentData.en | Add-Member -NotePropertyName "headline" -NotePropertyValue (Translate-ToEnglish -ChineseText $contentData.zh.headline -FieldName "headline" -Config $apiConfig -ApiKey $ApiKey) -Force
    $contentData.en | Add-Member -NotePropertyName "source" -NotePropertyValue $contentData.zh.source -Force
    $contentData.en | Add-Member -NotePropertyName "sourceTime" -NotePropertyValue $contentData.zh.sourceTime -Force
    $contentData.en | Add-Member -NotePropertyName "summary" -NotePropertyValue (Translate-ToEnglish -ChineseText $contentData.zh.summary -FieldName "summary" -Config $apiConfig -ApiKey $ApiKey) -Force
    $contentData.en | Add-Member -NotePropertyName "newThreeViews" -NotePropertyValue (Translate-ToEnglish -ChineseText $contentData.zh.newThreeViews -FieldName "newThreeViews" -Config $apiConfig -ApiKey $ApiKey) -Force
    $contentData.en | Add-Member -NotePropertyName "normative" -NotePropertyValue (Translate-ToEnglish -ChineseText $contentData.zh.normative -FieldName "normative" -Config $apiConfig -ApiKey $ApiKey) -Force
    $contentData.en | Add-Member -NotePropertyName "longTermImpact" -NotePropertyValue (Translate-ToEnglish -ChineseText $contentData.zh.longTermImpact -FieldName "longTermImpact" -Config $apiConfig -ApiKey $ApiKey) -Force
    $contentData.en | Add-Member -NotePropertyName "reflectionQ1" -NotePropertyValue (Translate-ToEnglish -ChineseText $contentData.zh.reflectionQ1 -FieldName "reflectionQ1" -Config $apiConfig -ApiKey $ApiKey) -Force
    $contentData.en | Add-Member -NotePropertyName "reflectionQ2" -NotePropertyValue (Translate-ToEnglish -ChineseText $contentData.zh.reflectionQ2 -FieldName "reflectionQ2" -Config $apiConfig -ApiKey $ApiKey) -Force
    
    # Handle tags
    if ($contentData.zh.tags) {
        $tagsText = $contentData.zh.tags -join ", "
        $translatedTags = Translate-ToEnglish -ChineseText $tagsText -FieldName "tags" -Config $apiConfig -ApiKey $ApiKey
        $contentData.en | Add-Member -NotePropertyName "tags" -NotePropertyValue ($translatedTags -split ",\s*") -Force
    }
    
    Write-ColorOutput "✓ Translation complete!" "Green"
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
    
    if ($CardType -eq "Commentary" -or $CardType -eq "评论") {
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
    
    $archiveFiles = Get-ChildItem -Path $ArchiveDir -Filter "news-*-$Language.html" | Sort-Object Name -Descending
    
    $cardsHtml = ""
    foreach ($file in $archiveFiles) {
        if ($file.Name -match "news-(\d{4}-\d{2}-\d{2})-") {
            $date = $matches[1]
            $content = Get-Content -Raw -Path $file.FullName -Encoding UTF8
            
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
            
            git add public/en/daily-commentary.html public/zh/每日热点评论.html public/en/news/ public/zh/news/ public/index.html public/zh/首页.html
            
            $commitMsg = "📰 Daily commentary - $publishDate"
            git commit -m $commitMsg
            
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
    Write-ColorOutput "Provider: $($apiConfig.Name)" "Cyan"
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
    Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" "DarkGray"
    exit 1
}

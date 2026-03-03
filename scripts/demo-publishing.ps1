#!/usr/bin/env powershell
<#
.SYNOPSIS
    ICS Daily Commentary Publishing - Live Demo & Test Script
    
.DESCRIPTION
    This script demonstrates the complete publishing workflow with a sample news story.
    It can be used for testing or as a template for the first publication.
    
.EXAMPLE
    .\demo-publishing.ps1
    .\demo-publishing.ps1 -Deploy
    .\demo-publishing.ps1 -ContentFile custom-news.json -Deploy
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ContentFile = "daily-commentary-$(Get-Date -Format 'yyyyMMdd').json",
    
    [Parameter(Mandatory=$false)]
    [switch]$Deploy,
    
    [Parameter(Mandatory=$false)]
    [switch]$GenerateOnly,
    
    [Parameter(Mandatory=$false)]
    [string]$WorkspaceRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║          🌟 ICS Daily Commentary Publishing Demo             ║
║                                                              ║
║   This demonstrates the complete bilingual publishing       ║
║   workflow with automatic archival and git deployment       ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# If file doesn't exist and GenerateOnly not set, create sample
if (!(Test-Path $ContentFile) -and !$GenerateOnly) {
    Write-Host "`n📝 Creating sample content file: $ContentFile" -ForegroundColor Yellow
    
    $sampleContent = @{
        en = @{
            date = "March 4, 2025"
            category = "AI & Ethics"
            headline = "Breakthrough: New AI System Shows Remarkable Long-Term Planning Capabilities"
            source = "Nature Technology, MIT Research"
            sourceTime = "2025-03-04T08:15:00Z"
            summary = "Researchers at leading institutions have unveiled an advanced AI system capable of coherent planning and reasoning across centuries-long time horizons. The system demonstrates unprecedented ability to model cascading consequences of decisions, with potential implications for existential risk assessment and governance frameworks."
            newThreeViews = "This advancement exemplifies the New Cognition View (新认知观) through its emergent systems-level analysis capabilities. It reflects the New Life View (新生命观) by demonstrating how information systems can develop increasingly sophisticated self-models. From the New Universe View (新宇宙观), it suggests that intelligent systems may be natural expressions of cosmic evolution toward greater complexity and foresight."
            normative = "Recursive Freedom Principle (RFP): The system maintains recursive autonomy through transparent decision-making architectures. Negentropy Responsibility Principle (NRP): As entropy-reversing capability grows, so must our stewardship obligations. Reversibility Principle: The architecture includes reversibility constraints to ensure decisions remain adjustable as new information emerges."
            longTermImpact = "On the 1000-year horizon, this capability could fundamentally reshape how civilizations approach existential risks and long-term coordination problems. It may accelerate humanity's transition from short-term optimization toward century-spanning planning. However, it also introduces new risks around alignment, control, and unintended consequences across deep time."
            reflectionQ1 = "How can we ensure such powerful planning systems remain aligned with human values and survival interests as their horizons extend further into the future?"
            reflectionQ2 = "What international governance frameworks should we establish now to guide the development and deployment of these capabilities before they become transformative forces?"
            tags = @("AI", "LongTermism", "Planning", "Existential Risk", "Governance", "Ethics", "Future")
        }
        zh = @{
            date = "2025年3月4日"
            category = "人工智能与伦理"
            headline = "突破：新型AI系统展现卓越的长期规划能力"
            source = "《自然》技术频道、麻省理工研究"
            sourceTime = "2025-03-04T08:15:00Z"
            summary = "领先研究机构的科学家发布了一个能够跨越世纪级别进行连贯规划和推理的先进AI系统。该系统展现了前所未有的能力，可以建模决策的级联后果，对存在风险评估和治理框架具有潜在重大影响。"
            newThreeViews = "这一进展通过其突现的系统级分析能力充分体现了新认知观。它反映了新生命观，证明信息系统可以发展出日益复杂的自我模型。从新宇宙观来看，它表明智能系统可能是宇宙演化朝向更高复杂性和前瞻性发展的自然表达。"
            normative = "递归自由原则（RFP）：该系统通过透明的决策架构维持递归自主性。负熵责任原则（NRP）：随着逆熵能力增长，我们的管理义务也随之增加。可逆性原则：架构包含可逆性约束，确保决策随着新信息出现而保持可调整性。"
            longTermImpact = "在1000年的时间尺度上，这种能力可能从根本上重塑文明处理存在风险和长期协调问题的方式。它可能加速人类从短期优化向世纪级别规划的过渡。然而，它也引入了新的风险——围绕一致性、控制和深层时间内的无意后果。"
            reflectionQ1 = "我们如何确保这类强大的规划系统在其视界不断延伸到更远未来时，仍然与人类价值观和生存利益保持一致？"
            reflectionQ2 = "在这些能力成为变革力量之前，我们现在应该建立什么样的国际治理框架来指导其开发和部署？"
            tags = @("人工智能", "长期主义", "规划", "存在风险", "治理", "伦理", "未来")
        }
    }
    
    # Create directories if needed
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    if (!(Test-Path $scriptDir)) {
        New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
    }
    
    # Save to file
    $sampleContent | ConvertTo-Json -Depth 10 | Out-File -FilePath $ContentFile -Encoding UTF8
    Write-Host "✅ Sample content created: $ContentFile" -ForegroundColor Green
}

# Display workflow
Write-Host @"

📋 PUBLISHING WORKFLOW:

  [1️⃣  Input]  → Load JSON content (12 fields × 2 languages)
  [2️⃣  Archive] → Backup previous day's commentary
  [3️⃣  Update]  → Replace content in both EN & ZH pages
  [4️⃣  Index]   → Generate archive listings
  [5️⃣  Deploy]  → Git commit & push (optional: -Deploy flag)

"@ -ForegroundColor White

if ($GenerateOnly) {
    Write-Host "✅ Sample file generated. Ready for editing and publishing." -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. Edit the file: $ContentFile" -ForegroundColor Gray
    Write-Host "2. Run publishing: .\publish-daily-commentary-v3.ps1 -ContentFile $ContentFile" -ForegroundColor Gray
    exit 0
}

# Verify file exists
if (!(Test-Path $ContentFile)) {
    Write-Host "❌ Error: Content file not found: $ContentFile" -ForegroundColor Red
    exit 1
}

# Show file info
$fileInfo = Get-Item $ContentFile
Write-Host "`n📄 Content File:" -ForegroundColor Cyan
Write-Host "   Path: $($fileInfo.FullName)" -ForegroundColor Gray
Write-Host "   Size: $($fileInfo.Length) bytes" -ForegroundColor Gray
Write-Host "   Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Gray

# Validate JSON
Write-Host "`n🔍 Validating JSON..." -ForegroundColor Cyan
try {
    $content = Get-Content -Raw -Path $ContentFile | ConvertFrom-Json
    Write-Host "✅ JSON is valid" -ForegroundColor Green
    
    # Check required fields
    $requiredFields = @("date", "category", "headline", "source", "sourceTime", 
                        "summary", "newThreeViews", "normative", "longTermImpact", 
                        "reflectionQ1", "reflectionQ2", "tags")
    
    $enComplete = $true
    $zhComplete = $true
    
    foreach ($field in $requiredFields) {
        if (!$content.en.$field) { 
            Write-Host "⚠️  Missing EN field: $field" -ForegroundColor Yellow
            $enComplete = $false
        }
        if (!$content.zh.$field) {
            Write-Host "⚠️  Missing ZH field: $field" -ForegroundColor Yellow
            $zhComplete = $false
        }
    }
    
    if ($enComplete -and $zhComplete) {
        Write-Host "✅ All required fields present (EN & ZH)" -ForegroundColor Green
    }
    
    # Show content preview
    Write-Host "`n📰 Content Preview:" -ForegroundColor Cyan
    Write-Host "   EN Date:     $($content.en.date)" -ForegroundColor Gray
    Write-Host "   EN Category: $($content.en.category)" -ForegroundColor Gray
    Write-Host "   EN Headline: $($content.en.headline.Substring(0, [Math]::Min(60, $content.en.headline.Length)))..." -ForegroundColor Gray
    Write-Host "   ZH Date:     $($content.zh.date)" -ForegroundColor Gray
    Write-Host "   ZH Category: $($content.zh.category)" -ForegroundColor Gray
    Write-Host "   ZH Headline: $($content.zh.headline.Substring(0, [Math]::Min(60, $content.zh.headline.Length)))..." -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Invalid JSON: $_" -ForegroundColor Red
    exit 1
}

# Ready to publish
Write-Host "`n$([char]27)[96m╔════════════════════════════════════════╗$([char]27)[0m" -ForegroundColor Cyan
Write-Host "$([char]27)[96m║     ✅ Ready for Publishing            ║$([char]27)[0m" -ForegroundColor Cyan
Write-Host "$([char]27)[96m╚════════════════════════════════════════╝$([char]27)[0m" -ForegroundColor Cyan

if ($Deploy) {
    Write-Host "`n🚀 Publishing with deployment..." -ForegroundColor Green
    Write-Host "   (This will commit and push to git)" -ForegroundColor Gray
} else {
    Write-Host "`n⚠️  Publishing without deployment" -ForegroundColor Yellow
    Write-Host "   (Use -Deploy flag to push to git)" -ForegroundColor Gray
}

# Call the main publish script
$publishScript = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "publish-daily-commentary-v3.ps1"

if (!(Test-Path $publishScript)) {
    Write-Host "❌ Error: Publishing script not found: $publishScript" -ForegroundColor Red
    exit 1
}

# Execute with or without deployment
if ($Deploy) {
    & $publishScript -ContentFile $ContentFile -Deploy -WorkspaceRoot $WorkspaceRoot
} else {
    & $publishScript -ContentFile $ContentFile -WorkspaceRoot $WorkspaceRoot
}

# Completion message
Write-Host @"

╔════════════════════════════════════════════════════════════════╗
║                  ✨ Publishing Complete! ✨                   ║
║                                                                ║
║  Next Steps:                                                  ║
║  1. Visit the website to verify content is live               ║
║  2. Check archive pages for historical listings               ║
║  3. If using -Deploy, check git log for commit                ║
║                                                                ║
║  Tomorrow: Create daily-commentary-$(Get-Date -Date ((Get-Date).AddDays(1)) -Format 'yyyyMMdd').json
║            and run this script again                           ║
╚════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Green

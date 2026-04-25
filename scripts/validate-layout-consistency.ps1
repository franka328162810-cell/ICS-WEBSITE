param(
    [Parameter(Mandatory=$false)]
    [switch]$InitBaseline,

    [Parameter(Mandatory=$false)]
    [string]$WorkspaceRoot = (Get-Location).Path
)

function Write-ColorOutput {
    param([string]$Text, [string]$ForegroundColor = "White")
    Write-Host $Text -ForegroundColor $ForegroundColor
}

function Normalize-Structure {
    param([string]$Html)

    # Keep markup, remove only data-field values
    $s = $Html
    $s = [regex]::Replace($s, '(<span[^>]*data-field="[^"]+"[^>]*>)(.*?)(</span>)', '$1__FIELD__$3', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $s = [regex]::Replace($s, '(<div[^>]*data-field="[^"]+"[^>]*>)(.*?)(</div>)', '$1__FIELD__$3', [System.Text.RegularExpressions.RegexOptions]::Singleline)

    # Normalize whitespace noise
    $s = [regex]::Replace($s, '>\s+<', '><')
    $s = [regex]::Replace($s, '\s{2,}', ' ')
    return $s.Trim()
}

function Get-StringHash {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $hash = $sha.ComputeHash($bytes)
    return ([System.BitConverter]::ToString($hash) -replace '-', '').ToLower()
}

function Resolve-TargetFiles {
    param([string]$Root)

    $enDaily = Join-Path $Root "public/en/daily-commentary.html"
    $enResearch = Join-Path $Root "public/en/in-depth-research.html"

    $zhDir = Join-Path $Root "public/zh"
    if (!(Test-Path $zhDir)) {
        throw "Missing directory: public/zh"
    }

    $zhFiles = Get-ChildItem -Path $zhDir -Filter "*.html" -File
    $zhDaily = $null
    $zhResearch = $null

    foreach ($f in $zhFiles) {
        $raw = Get-Content -Raw -Path $f.FullName -Encoding UTF8
        if (!$zhDaily -and $raw -match '<body[^>]*data-page="news-daily"') {
            $zhDaily = $f.FullName
        }
        if (!$zhResearch -and $raw -match '<body[^>]*data-page="research-deep"') {
            $zhResearch = $f.FullName
        }
    }

    if (!$zhDaily) { throw "Cannot locate Chinese daily commentary page in public/zh" }
    if (!$zhResearch) { throw "Cannot locate Chinese in-depth research page in public/zh" }

    return @(
        @{ key = "daily_en"; fullPath = $enDaily; displayPath = "public/en/daily-commentary.html" },
        @{ key = "daily_zh"; fullPath = $zhDaily; displayPath = (Resolve-Path -LiteralPath $zhDaily).Path.Replace($Root + '\\', '').Replace('\\', '/') },
        @{ key = "research_en"; fullPath = $enResearch; displayPath = "public/en/in-depth-research.html" },
        @{ key = "research_zh"; fullPath = $zhResearch; displayPath = (Resolve-Path -LiteralPath $zhResearch).Path.Replace($Root + '\\', '').Replace('\\', '/') }
    )
}

function Test-BasicHtmlSafety {
    param([string]$Root)

    $publicDir = Join-Path $Root "public"
    if (!(Test-Path $publicDir)) {
        throw "Missing directory: public"
    }

    $htmlFiles = Get-ChildItem -Path $publicDir -Recurse -File -Filter "*.html"
    $brokenHrefPattern = 'href="/""'
    $jsHrefPattern = 'href\s*=\s*["'']\s*javascript:'
    $findings = @()

    foreach ($file in $htmlFiles) {
        $raw = Get-Content -Raw -Path $file.FullName -Encoding UTF8
        if ($raw -match $brokenHrefPattern) {
            $findings += "Broken href quote in $($file.FullName.Replace($Root + '\', '').Replace('\', '/'))"
        }
        if ($raw -imatch $jsHrefPattern) {
            $findings += "javascript: href found in $($file.FullName.Replace($Root + '\', '').Replace('\', '/'))"
        }
    }

    return $findings
}

$htmlSafetyFindings = Test-BasicHtmlSafety -Root $WorkspaceRoot
if ($htmlSafetyFindings.Count -gt 0) {
    Write-ColorOutput "❌ HTML safety checks failed:" "Red"
    foreach ($f in $htmlSafetyFindings) {
        Write-ColorOutput "  - $f" "Red"
    }
    exit 3
}

$targets = Resolve-TargetFiles -Root $WorkspaceRoot

$baselineFile = Join-Path $WorkspaceRoot "scripts/layout-baseline.hashes.json"
$current = @{}

foreach ($t in $targets) {
    $fullPath = $t.fullPath
    if (!(Test-Path $fullPath)) {
        Write-ColorOutput "❌ Missing file: $($t.displayPath)" "Red"
        exit 1
    }
    $raw = Get-Content -Raw -Path $fullPath -Encoding UTF8
    $norm = Normalize-Structure -Html $raw
    $current[$t.key] = Get-StringHash -Text $norm
}

if ($InitBaseline) {
    $json = $current | ConvertTo-Json -Depth 5
    Set-Content -Path $baselineFile -Value $json -Encoding UTF8
    Write-ColorOutput "✅ Baseline created: scripts/layout-baseline.hashes.json" "Green"
    exit 0
}

if (!(Test-Path $baselineFile)) {
    Write-ColorOutput "⚠ Baseline not found. Run with -InitBaseline first." "Yellow"
    exit 1
}

$baseline = Get-Content -Raw -Path $baselineFile -Encoding UTF8 | ConvertFrom-Json
$failed = $false

Write-ColorOutput "🔍 Validating layout/style/structure consistency..." "Cyan"
foreach ($t in $targets) {
    $k = $t.key
    $oldHash = "$($baseline.$k)"
    $newHash = "$($current[$k])"

    if ($oldHash -eq $newHash) {
        Write-ColorOutput "  ✓ $($t.displayPath)" "Green"
    } else {
        Write-ColorOutput "  ✗ $($t.displayPath)" "Red"
        $failed = $true
    }
}

if ($failed) {
    Write-ColorOutput "\n❌ Structure changed. Please review template/layout modifications." "Red"
    exit 2
}

Write-ColorOutput "\n✅ 100% consistent: layout/style/structure unchanged (content-only updates)." "Green"
exit 0

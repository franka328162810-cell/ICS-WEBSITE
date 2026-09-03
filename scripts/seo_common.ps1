function Encode-HtmlAttribute {
    param([string]$Value)
    if ($null -eq $Value) { return "" }
    $Value = $Value -replace '&', '&amp;'
    $Value = $Value -replace '<', '&lt;'
    $Value = $Value -replace '>', '&gt;'
    $Value = $Value -replace '"', '&quot;'
    $Value = $Value -replace "'", '&#39;'
    return $Value
}

function Remove-ExistingSeoBlock {
    param([string]$Html)
    return [regex]::Replace($Html, '(?s)<!--\s*ICS-SEO-START\s*-->.*?<!--\s*ICS-SEO-END\s*-->', '', [Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

function Get-SeoBlock {
    param(
        [string]$Title,
        [string]$Description,
        [string]$Url,
        [string]$Locale,
        [string]$AlternateLocale,
        [string]$AlternateUrl,
        [string]$SiteName,
        [string]$Author,
        [string]$PublishedTime,
        [string]$OgType = 'article',
        [string]$TwitterCard = 'summary_large_image',
        [string]$ImageUrl = 'https://ics-studies.org/images/og-default.jpg',
        [string]$ImageWidth = '1200',
        [string]$ImageHeight = '630',
        [string]$ImageType = 'image/jpeg'
    )

    $safeTitle = Encode-HtmlAttribute $Title
    $safeDescription = Encode-HtmlAttribute $Description
    $safeUrl = Encode-HtmlAttribute $Url
    $safeLocale = Encode-HtmlAttribute $Locale
    $safeAlternateLocale = Encode-HtmlAttribute $AlternateLocale
    $safeAlternateUrl = Encode-HtmlAttribute $AlternateUrl
    $safeSiteName = Encode-HtmlAttribute $SiteName
    $safeAuthor = Encode-HtmlAttribute $Author
    $safePublishedTime = Encode-HtmlAttribute $PublishedTime
    $safeImageUrl = Encode-HtmlAttribute $ImageUrl
    $safeImageWidth = Encode-HtmlAttribute $ImageWidth
    $safeImageHeight = Encode-HtmlAttribute $ImageHeight
    $safeImageType = Encode-HtmlAttribute $ImageType

    $canonicalLine = ''
    if ([string]::IsNullOrWhiteSpace($safeUrl) -eq $false) {
        $canonicalLine = "    <link rel=""canonical"" href=""$safeUrl"">`n"
    }

    $selfAlternateLine = ''
    if ([string]::IsNullOrWhiteSpace($safeLocale) -eq $false -and [string]::IsNullOrWhiteSpace($safeUrl) -eq $false) {
        $selfAlternateLine = "    <link rel=""alternate"" hreflang=""$safeLocale"" href=""$safeUrl"">`n"
    }

    $alternateLinkLine = ''
    if ([string]::IsNullOrWhiteSpace($safeAlternateLocale) -eq $false -and [string]::IsNullOrWhiteSpace($safeAlternateUrl) -eq $false) {
        $alternateLinkLine = "    <link rel=""alternate"" hreflang=""$safeAlternateLocale"" href=""$safeAlternateUrl"">`n"
    }

    $ogLocaleAlternateLine = ''
    if ([string]::IsNullOrWhiteSpace($safeAlternateLocale) -eq $false) {
        $ogLocaleAlternateLine = "    <meta property=""og:locale:alternate"" content=""$safeAlternateLocale"">`n"
    }

    $xDefaultHref = $safeUrl
    if ([string]::IsNullOrWhiteSpace($safeAlternateUrl) -eq $false -and $safeAlternateLocale -match '^en') {
        $xDefaultHref = $safeAlternateUrl
    }

    $xDefaultLine = ''
    if ([string]::IsNullOrWhiteSpace($xDefaultHref) -eq $false) {
        $xDefaultLine = "    <link rel=""alternate"" hreflang=""x-default"" href=""$xDefaultHref"">`n"
    }

    $urlLine = ''
    if ([string]::IsNullOrWhiteSpace($safeUrl) -eq $false) {
        $urlLine = "    <meta property=""og:url"" content=""$safeUrl"">`n"
    }

    return @"
    <!-- ICS-SEO-START -->
${canonicalLine}${selfAlternateLine}${alternateLinkLine}${xDefaultLine}    <meta name="description" content="$safeDescription">`n
    <meta property="og:type" content="$OgType">`n
    <meta property="og:title" content="$safeTitle">`n
    <meta property="og:description" content="$safeDescription">`n
${urlLine}    <meta property="og:site_name" content="$safeSiteName">`n
    <meta property="og:locale" content="$safeLocale">`n
${ogLocaleAlternateLine}    <meta property="og:image" content="$safeImageUrl">`n
    <meta property="og:image:width" content="$safeImageWidth">`n
    <meta property="og:image:height" content="$safeImageHeight">`n
    <meta property="og:image:type" content="$safeImageType">`n
    <meta name="twitter:card" content="$TwitterCard">`n
    <meta name="twitter:title" content="$safeTitle">`n
    <meta name="twitter:description" content="$safeDescription">`n
    <meta name="twitter:image" content="$safeImageUrl">`n
    <script type="application/ld+json">`n
    {`n
      "@context": "https://schema.org",`n
      "@type": "ScholarlyArticle",`n
      "headline": "$safeTitle",`n
      "datePublished": "$safePublishedTime",`n
      "author": {"@type": "Organization", "name": "$safeAuthor"},`n
      "publisher": {"@type": "Organization", "name": "$safeSiteName"},`n
      "description": "$safeDescription",`n
      "mainEntityOfPage": {`n
        "@type": "WebPage",`n
        "@id": "$safeUrl"`n
      }`n
    }`n
    </script>`n
    <!-- ICS-SEO-END -->
"@
}

function Inject-SeoBlock {
    param(
        [string]$Html,
        [string]$Title,
        [string]$Description,
        [string]$Url,
        [string]$Locale,
        [string]$AlternateLocale,
        [string]$AlternateUrl,
        [string]$SiteName,
        [string]$Author,
        [string]$PublishedTime
    )

    $Html = Remove-ExistingSeoBlock -Html $Html
    $seoBlock = Get-SeoBlock -Title $Title -Description $Description -Url $Url -Locale $Locale -AlternateLocale $AlternateLocale -AlternateUrl $AlternateUrl -SiteName $SiteName -Author $Author -PublishedTime $PublishedTime

    if ($Html -match '</head>') {
        return $Html -replace '</head>', "$seoBlock`n</head>"
    }

    throw 'SEO INJECTION FAILED: </head> tag not found.'
}

function Validate-SeoTags {
    param([string]$Html, [string]$Path)
    $required = @(
        '<link rel="canonical"',
        '<link rel="alternate" hreflang',
        '<meta property="og:title"',
        '<meta property="og:description"',
        '<meta name="twitter:card"',
        '<script type="application/ld\+json"'
    )

    $missing = @()
    foreach ($pattern in $required) {
        if (-not [regex]::IsMatch($Html, [regex]::Escape($pattern), [Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            $missing += $pattern
        }
    }

    if ($missing.Count -gt 0) {
        Write-Host ("Warning: SEO validation found missing tags in {0}`n  {1}" -f $Path, ($missing -join ', ')) -ForegroundColor Yellow
        return $false
    }

    return $true
}

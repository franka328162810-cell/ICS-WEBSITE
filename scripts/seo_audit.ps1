$files = Get-ChildItem -Path .\public -Recurse -Filter *.html
Write-Host "HTML_TOTAL= $($files.Count)"
$patterns = @{
    Seo = '<!-- ICS-SEO-START -->'
    Canonical = '<link rel="canonical"'
    OpenGraph = '<meta property="og:'
    Twitter = '<meta name="twitter:'
    JsonLd = '<script type="application/ld\+json"'
    Hreflang = '<link rel="alternate" hreflang'
}
foreach ($name in $patterns.Keys) {
    $count = Select-String -Path $files.FullName -Pattern $patterns[$name] -List | Measure-Object | Select-Object -ExpandProperty Count
    Write-Host "$name=`t$count"
}

$missingCanonical = $files | Where-Object { -not (Select-String -Path $_.FullName -Pattern $patterns['Canonical'] -Quiet) }
Write-Host "MISSING_CANONICAL= $($missingCanonical.Count)"
$missingCanonical | Select-Object -ExpandProperty FullName | Select-Object -First 20 | ForEach-Object { Write-Host $_ }

$missingOg = $files | Where-Object { -not (Select-String -Path $_.FullName -Pattern $patterns['OpenGraph'] -Quiet) }
Write-Host "MISSING_OG= $($missingOg.Count)"
$missingOg | Select-Object -ExpandProperty FullName | Select-Object -First 20 | ForEach-Object { Write-Host $_ }

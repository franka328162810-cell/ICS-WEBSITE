# Force replace /compass/ with # in all HTML files and record modified files
$changed = @()
Get-ChildItem -Recurse -Include *.html -File | ForEach-Object {
    $p = $_.FullName
    try {
        $t = Get-Content -Raw -Encoding UTF8 -ErrorAction Stop -Path $p
    } catch {
        $t = Get-Content -Raw -Encoding Default -Path $p
    }
    $nt = $t -replace '/compass/','#' -replace 'href="/compass/"','href="#"' -replace "href='/compass/'","href='#'"
    if ($t -ne $nt) {
        Set-Content -Encoding UTF8 -Value $nt -Path $p
        $changed += $p
        Write-Host "Updated: $p"
    }
}
Write-Host "Total updated files: $($changed.Count)"
if ($changed.Count -gt 0) {
    $changed | Out-File -Encoding UTF8 updated_compass_replacements.txt
}

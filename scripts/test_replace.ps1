$txt1 = '<h3 class="news-title" data-field="headline">Old</h3>'
$txt2 = '<p data-field="summary">Short summary</p>'
$txt3 = '<div class="question-item" data-field="reflectionQ1">Q1 text</div>'
foreach ($pair in @{
    headline=$txt1; summary=$txt2; reflectionQ1=$txt3
}) {
    $field = $pair.Key
    $txt = $pair.Value
    $regex = '(?<pre><(?<tag>[^ >]+)[^>]*data-field="' + [regex]::Escape($field) + '"[^>]*>)(.*?)(?<post></\k<tag>>)' 
    $out = $txt -replace $regex, "`${pre}NEW-${field}`${post}"
    Write-Host "Original: $txt"
    Write-Host "Result: $out"; Write-Host "---"
}
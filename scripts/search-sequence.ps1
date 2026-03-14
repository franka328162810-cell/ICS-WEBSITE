param(
    [string]$Path,
    [string]$SearchString
)
$seq = [System.Text.Encoding]::UTF8.GetBytes($SearchString)
$bytes = [System.IO.File]::ReadAllBytes($Path)
for ($i = 0; $i -le $bytes.Length - $seq.Length; $i++) {
    $found = $true
    for ($j = 0; $j -lt $seq.Length; $j++) {
        if ($bytes[$i+$j] -ne $seq[$j]) { $found = $false; break }
    }
    if ($found) {
        Write-Host "Found at index $i"
        return
    }
}
Write-Host "Not found"

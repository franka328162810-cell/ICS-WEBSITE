param(
    [string]$Path = "scripts/generate-daily-commentary.ps1"
)

$full = Join-Path $PSScriptRoot "..\$Path"
$bytes = [System.IO.File]::ReadAllBytes($full)

function Find-Seq([byte[]]$seq) {
    for ($i=0; $i -le $bytes.Length - $seq.Length; $i++) {
        $match = $true
        for ($j=0; $j -lt $seq.Length; $j++) {
            if ($bytes[$i+$j] -ne $seq[$j]) { $match = $false; break }
        }
        if ($match) { return $i }
    }
    return -1
}

$pos = Find-Seq -seq ([byte[]](0xE7,0xBA,0xA6))
Write-Host "Position of UTF-8 '约' byte sequence:" $pos

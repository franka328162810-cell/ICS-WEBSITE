param(
    [string]$Path,
    [int]$Start = 0,
    [int]$Length = 40
)
$bytes = [System.IO.File]::ReadAllBytes($Path)
$end = [Math]::Min($bytes.Length - 1, $Start + $Length - 1)
$slice = $bytes[$Start..$end]
$decoded = [System.Text.Encoding]::UTF8.GetString($slice)
Write-Host "Decoded string from bytes ${Start}..${end}:"
Write-Host $decoded

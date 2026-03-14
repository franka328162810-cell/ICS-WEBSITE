param(
    [string]$FilePath,
    [int]$Start = 0,
    [int]$Length = 64
)
$bytes = [System.IO.File]::ReadAllBytes($FilePath)
$end = [Math]::Min($bytes.Length - 1, $Start + $Length - 1)
$slice = $bytes[$Start..$end]
Write-Host "Bytes [$Start..$end]:" ($slice | ForEach-Object { '{0:X2}' -f $_ })
$decoded = [System.Text.Encoding]::UTF8.GetString($slice)
Write-Host "Decoded:"
Write-Host $decoded

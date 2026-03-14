@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "file=C:\Users\Administrator\Documents\ics-website\public\zh\首页.html"

powershell -Command "(Get-Content '%file%' -Raw -Encoding UTF8) -replace 'class=\"news-tab\" onclick=\"alert\(''.*?''\)\"','style=\"display:none\"' | Set-Content '%file%' -Encoding UTF8 -NoNewline"

echo Done

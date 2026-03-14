[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$content = Get-Content -Path "C:\Users\Administrator\Documents\ics-website\public\zh\首页.html" -Raw

# Simple replacements using simple string matching
$content = $content -replace '<div class="news-tabs">\s*<a href="每日热点评论.html" class="news-tab active">评论</a>\s*<a href="深度研究.html" class="news-tab">研究</a>\s*<button class="news-tab" onclick="alert.*?</button>\s*</div>', ''

$content = $content -replace '<div class="unified-card">\s*<div class="card-header-bar"></div>\s*<div class="card-body">\s*<span class="card-tag">评论</span>\s*<h3 class="card-title">.*?特朗普封杀Anthropic.*?</h3>\s*<p class="card-text">.*?</p>\s*</div>\s*</div>', '<a href="每日热点评论.html" class="unified-card" style="text-decoration:none;color:inherit;"><div class="card-header-bar"></div><div class="card-body"><span class="card-tag">评论</span><h3 class="card-title">特朗普封杀Anthropic：AI军事化道路上的第一个文明级伦理临界点</h3><p class="card-text">政策封禁与军事依赖并存，AI治理可逆性面临现实压力...</p></div><div style="padding:0 2rem 1.5rem;text-align:right;"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#a78bfa" stroke-width="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg></div></a>'

$content = $content -replace '<div class="unified-card">\s*<div class="card-header-bar"></div>\s*<div class="card-body">\s*<span class="card-tag">研究</span>\s*<h3 class="card-title">.*?特朗普封杀Anthropic.*?</h3>\s*<p class="card-text">.*?</p>\s*</div>\s*</div>', '<a href="深度研究.html" class="unified-card" style="text-decoration:none;color:inherit;"><div class="card-header-bar"></div><div class="card-body"><span class="card-tag">研究</span><h3 class="card-title">特朗普封杀Anthropic：AI伦理红线与军事需求的文明级博弈</h3><p class="card-text">从递归自由原则和可逆性原则分析AI军事化路径的深远影响...</p></div><div style="padding:0 2rem 1.5rem;text-align:right;"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#a78bfa" stroke-width="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg></div></a>'

$content | Out-File -FilePath "C:\Users\Administrator\Documents\ics-website\public\zh\首页.html" -Encoding UTF8
Write-Host "Done"

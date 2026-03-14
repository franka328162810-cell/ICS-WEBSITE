const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'public', 'zh', '首页.html');

console.log('Reading file from:', filePath);

let content = fs.readFileSync(filePath, 'utf8');
console.log('File read successfully, length:', content.length);

// Remove news-tabs
content = content.replace(
    /<div class="news-tabs">\s*<a href="每日热点评论\.html" class="news-tab active">评论<\/a>\s*<a href="深度研究\.html" class="news-tab">研究<\/a>\s*<button class="news-tab" onclick="alert\('年度报告下一年度上线，敬请期待！'\)">年度报告<\/button>\s*<\/div>/g,
    ''
);

// First card - make it a link
content = content.replace(
    /<div class="unified-card">\s*<div class="card-header-bar"><\/div>\s*<div class="card-body">\s*<span class="card-tag">评论<\/span>\s*<h3 class="card-title">特朗普封杀Anthropic：AI军事化道路上的第一个文明级伦理临界点<\/h3>\s*<p class="card-text">政策封禁与军事依赖并存，AI治理可逆性面临现实压力\.\.\.<\/p>\s*<\/div>\s*<\/div>/g,
    `<a href="每日热点评论.html" class="unified-card" style="text-decoration:none;color:inherit;">
                    <div class="card-header-bar"></div>
                    <div class="card-body">
                        <span class="card-tag">评论</span>
                        <h3 class="card-title">特朗普封杀Anthropic：AI军事化道路上的第一个文明级伦理临界点</h3>
                        <p class="card-text">政策封禁与军事依赖并存，AI治理可逆性面临现实压力...</p>
                    </div>
                    <div style="padding:0 2rem 1.5rem;text-align:right;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#a78bfa" stroke-width="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                    </div>
                </a>`
);

// Second card - make it a link
content = content.replace(
    /<div class="unified-card">\s*<div class="card-header-bar"><\/div>\s*<div class="card-body">\s*<span class="card-tag">研究<\/span>\s*<h3 class="card-title">特朗普封杀Anthropic：AI伦理红线与军事需求的文明级博弈<\/h3>\s*<p class="card-text">从递归自由原则和可逆性原则分析AI军事化路径的深远影响\.\.\.<\/p>\s*<\/div>\s*<\/div>/g,
    `<a href="深度研究.html" class="unified-card" style="text-decoration:none;color:inherit;">
                    <div class="card-header-bar"></div>
                    <div class="card-body">
                        <span class="card-tag">研究</span>
                        <h3 class="card-title">特朗普封杀Anthropic：AI伦理红线与军事需求的文明级博弈</h3>
                        <p class="card-text">从递归自由原则和可逆性原则分析AI军事化路径的深远影响...</p>
                    </div>
                    <div style="padding:0 2rem 1.5rem;text-align:right;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#a78bfa" stroke-width="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                    </div>
                </a>`
);

fs.writeFileSync(filePath, content, 'utf8');
console.log('File written successfully');

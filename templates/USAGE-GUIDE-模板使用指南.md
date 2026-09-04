# ICS网站HTML模板使用指南

## 📋 目录
1. [模板文件概览](#模板文件概览)
2. [变量占位符说明](#变量占位符说明)
3. [使用方法](#使用方法)
4. [完整示例](#完整示例)
5. [常见问题](#常见问题)

---

## 📁 模板文件概览

### 已创建的模板文件

#### 深度研究模板
- **中文版**: `templates/in-depth-research-zh-template.html`
- **英文版**: `templates/in-depth-research-en-template.html`
- **用途**: 用于发布长篇深度分析文章（通常25分钟以上阅读时长）

#### 每日热点评论模板
- **中文版**: `templates/daily-commentary-zh-template.html`  
- **英文版**: `templates/daily-commentary-en-template.html`
- **用途**: 用于发布每日新闻评论文章（通常5-15分钟阅读时长）

---

## 🔖 变量占位符说明

### 深度研究模板变量（13个必填字段）

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `{{TITLE}}` | 文章标题 | "特朗普封杀Anthropic：AI伦理红线与军事需求的文明级博弈" |
| `{{DESCRIPTION}}` | SEO描述（建议120字以内） | "AI伦理红线与军事需求的文明级博弈" |
| `{{FILENAME}}` | 当前文件名（无扩展名） | "深度研究" |
| `{{FILENAME_EN}}` | 英文版文件名 | "in-depth-research" |
| `{{DATE}}` | 发布日期 | "2026年3月4日" 或 "2026-03-04" |
| `{{AUTHOR}}` | 作者 | "星际文明学研究所" |
| `{{READING_TIME}}` | 阅读时长 | "25分钟" |
| `{{CATEGORY}}` | 分类标签 | "AI治理" |
| `{{ABSTRACT}}` | 摘要/引言（显示在顶部卡片） | 200-300字的文章概要 |
| `{{YEAR}}` | 年份（用于引用） | "2026" |
| `{{MAIN_CONTENT}}` | 文章主要内容（完整HTML） | 包含所有section、content-card等结构的HTML |
| `{{RELATED_RESEARCH}}` | 相关研究链接（3个推荐卡片） | 3个related-card的HTML代码 |
| `{{FILENAME_ZH}}` | 中文版文件名（英文模板用） | "深度研究" |

### 每日热点评论模板变量（12个必填字段）

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `{{HEADLINE}}` | 新闻标题 | "OpenAI发布GPT-5：通用人工智能的新里程碑" |
| `{{SHORT_SUMMARY}}` | 简短摘要（1-2句话） | "OpenAI今日发布了GPT-5，标志着通用人工智能研发的重大突破..." |
| `{{FILENAME}}` | 当前文件名 | "gpt5-20250115" |
| `{{FILENAME_EN}}` | 英文版文件名 | "gpt5-20250115" |
| `{{DATE}}` | 发布日期 | "2025年1月15日" |
| `{{READING_TIME}}` | 阅读时长 | "8分钟" |
| `{{MAIN_CONTENT}}` | 文章主要内容 | 完整HTML内容 |
| `{{RELATED_ARTICLES}}` | 相关文章（3个卡片） | 3个related-card的HTML |
| `{{FILENAME_ZH}}` | 中文版文件名（英文模板用） | "gpt5-20250115" |
| `{{YEAR}}` | 年份（SEO用） | "2025" |
| `{{AUTHOR}}` | 作者（SEO用） | "星际文明学研究所" |
| `{{CATEGORY}}` | 分类（如需要） | "AI前沿" |

---

## 💡 使用方法

### 方法一：手动替换（适合单篇文章）

1. **复制模板文件**
   ```bash
   # 发布深度研究文章
   cp templates/in-depth-research-zh-template.html public/zh/我的新文章.html
   
   # 发布每日热点评论
   cp templates/daily-commentary-zh-template.html public/zh/daily-commentary-archive/gpt5-20250115.html
   ```

2. **使用文本编辑器打开文件**
   - 推荐使用VS Code、Sublime Text等支持查找替换的编辑器

3. **替换变量**
   - 使用"查找替换"功能（Ctrl+H）
   - 逐个替换`{{VARIABLE}}`为实际内容
   - **注意**: `{{MAIN_CONTENT}}`需要替换为完整的HTML结构

4. **保存并预览**
   - 在浏览器中打开文件预览
   - 检查所有内容是否正确显示

### 方法二：通过PowerShell脚本（推荐，自动化）

#### 脚本示例：自动替换变量

```powershell
# 定义变量映射
$variables = @{
    "{{TITLE}}" = "特朗普封杀Anthropic：AI伦理红线与军事需求的文明级博弈"
    "{{DESCRIPTION}}" = "AI伦理红线与军事需求的文明级博弈"
    "{{FILENAME}}" = "深度研究"
    "{{FILENAME_EN}}" = "in-depth-research"
    "{{DATE}}" = "2026年3月4日"
    "{{AUTHOR}}" = "星际文明学研究所"
    "{{READING_TIME}}" = "25分钟"
    "{{CATEGORY}}" = "AI治理"
    "{{YEAR}}" = "2026"
}

# 读取模板
$template = Get-Content "templates/in-depth-research-zh-template.html" -Raw -Encoding UTF8

# 替换所有变量
foreach ($key in $variables.Keys) {
    $template = $template -replace [regex]::Escape($key), $variables[$key]
}

# 保存到目标文件
$template | Out-File "public/zh/深度研究.html" -Encoding UTF8
```

### 方法三：整合到现有发布脚本

修改现有的`publish-research-v4-seo.ps1`脚本，在生成HTML时使用模板：

```powershell
# 读取模板
$templatePath = "templates/in-depth-research-zh-template.html"
$template = Get-Content $templatePath -Raw -Encoding UTF8

# 从JSON读取数据并替换变量
$jsonData = Get-Content "scripts/in-depth-research-data.json" | ConvertFrom-Json

$html = $template
$html = $html -replace '{{TITLE}}', $jsonData.title
$html = $html -replace '{{DESCRIPTION}}', $jsonData.description
# ... 继续替换其他变量

# 保存生成的HTML
$html | Out-File $outputPath -Encoding UTF8
```

---

## 📝 完整示例

### 示例1：发布深度研究文章

#### 步骤1：准备内容变量

```json
{
  "title": "特朗普封杀Anthropic：AI伦理红线与军事需求的文明级博弈",
  "description": "AI伦理红线与军事需求的文明级博弈",
  "filename": "深度研究",
  "filename_en": "in-depth-research",
  "date": "2026年3月4日",
  "author": "星际文明学研究所",
  "reading_time": "25分钟",
  "category": "AI治理",
  "abstract": "美国国防部采取了史无前例的举措，将一家本土科技公司Anthropic标记为"国家安全供应链风险"...",
  "year": "2026"
}
```

#### 步骤2：准备主要内容HTML

```html
<!-- 执行摘要 -->
<section>
    <h2 class="zh-section-title">执行摘要</h2>
    <div class="content-card">
        <p>美国国防部采取了史无前例的举措...</p>
    </div>
</section>

<!-- 第一部分：新闻事实 -->
<section>
    <h2 class="zh-section-title">一、新闻事实</h2>
    <h3 class="zh-subsection-title">1.1 封杀令出台</h3>
    <div class="content-card">
        <p>美国总统特朗普签署行政命令...</p>
    </div>
</section>

<!-- ... 更多章节 -->
```

#### 步骤3：准备相关研究链接

```html
<a href="research-deep-2.html" class="related-card">
    <span class="related-card-tag">深度研究</span>
    <h3 class="related-card-title">跨基质生命的伦理地位</h3>
    <p class="related-card-desc">探讨硅基生命、数字生命等非碳基生命形式的道德地位问题...</p>
</a>
<a href="research-deep-3.html" class="related-card">
    <span class="related-card-tag">深度研究</span>
    <h3 class="related-card-title">协议栈方法论在太空治理中的应用</h3>
    <p class="related-card-desc">运用分层、可演化的协议栈框架设计火星殖民地的治理结构...</p>
</a>
```

#### 步骤4：使用PowerShell脚本生成

```powershell
# 完整脚本示例
$jsonData = Get-Content "article-data.json" -Raw | ConvertFrom-Json
$template = Get-Content "templates/in-depth-research-zh-template.html" -Raw -Encoding UTF8
$mainContent = Get-Content "article-main-content.html" -Raw -Encoding UTF8
$relatedLinks = Get-Content "article-related.html" -Raw -Encoding UTF8

# 替换所有变量
$html = $template
$html = $html -replace '{{TITLE}}', $jsonData.title
$html = $html -replace '{{DESCRIPTION}}', $jsonData.description
$html = $html -replace '{{FILENAME}}', $jsonData.filename
$html = $html -replace '{{FILENAME_EN}}', $jsonData.filename_en
$html = $html -replace '{{DATE}}', $jsonData.date
$html = $html -replace '{{AUTHOR}}', $jsonData.author
$html = $html -replace '{{READING_TIME}}', $jsonData.reading_time
$html = $html -replace '{{CATEGORY}}', $jsonData.category
$html = $html -replace '{{ABSTRACT}}', $jsonData.abstract
$html = $html -replace '{{YEAR}}', $jsonData.year
$html = $html -replace '{{MAIN_CONTENT}}', $mainContent
$html = $html -replace '{{RELATED_RESEARCH}}', $relatedLinks

# 保存
$html | Out-File "public/zh/深度研究.html" -Encoding UTF8
Write-Host "✅ 文章已生成！" -ForegroundColor Green
```

---

## ❓ 常见问题

### Q1: 变量替换后中文显示乱码怎么办？
**A**: 确保文件编码为UTF-8:
```powershell
# 正确的保存方式
$content | Out-File "output.html" -Encoding UTF8

# 或使用Set-Content
$content | Set-Content "output.html" -Encoding UTF8
```

### Q2: `{{MAIN_CONTENT}}`应该包含什么？
**A**: 应该包含完整的HTML结构，包括：
- `<section>` 标签
- `<h2 class="zh-section-title">` 标题
- `<div class="content-card">` 内容卡片
- `<h3 class="zh-subsection-title">` 子标题
- 所有段落、列表、警告框等元素

### Q3: 如何确保SEO模块正确工作？
**A**: 检查以下内容：
1. `<!-- ICS-SEO-START -->` 和 `<!-- ICS-SEO-END -->` 标记存在
2. `{{TITLE}}`、`{{DESCRIPTION}}`、`{{DATE}}`、`{{AUTHOR}}` 都已正确替换
3. JSON-LD结构化数据中的字段完整

### Q4: 相关研究链接如何生成？
**A**: 使用以下HTML结构：
```html
<a href="目标文章.html" class="related-card">
    <span class="related-card-tag">深度研究</span>
    <h3 class="related-card-title">文章标题</h3>
    <p class="related-card-desc">文章简介（50字以内）...</p>
</a>
```
通常放置3个这样的卡片。

### Q5: 模板中的样式会自动应用吗？
**A**: 是的，所有CSS样式已内嵌在模板的`<style>`标签中，包括：
- ICS全局尺寸修复
- 导航栏、Hero区域、Footer样式
- 内容卡片、警告框、高亮框样式
- 响应式布局

### Q6: 如何批量生成多篇文章？
**A**: 建议：
1. 创建一个JSON文件存储所有文章的元数据
2. 为每篇文章单独准备主要内容HTML
3. 编写PowerShell循环脚本批量处理
```powershell
$articles = Get-Content "articles-list.json" | ConvertFrom-Json
foreach ($article in $articles) {
    # 读取模板
    # 替换变量
    # 保存文件
}
```

---

## 🎯 最佳实践

### 1. 版本控制
- 每次修改模板后，更新`template-variables.json`中的版本号
- 在README中记录模板变更历史

### 2. 内容分离
- 将文章元数据、主要内容、相关链接分别保存为独立文件
- 使用JSON格式存储元数据，便于程序读取

### 3. 自动化工作流
```
文章编写(Markdown/JSON) 
    → 内容转HTML 
    → 读取模板 
    → 变量替换 
    → 生成最终HTML 
    → Git提交推送
```

### 4. 质量检查清单
- [ ] 所有变量已替换（无`{{}}`残留）
- [ ] 中文编码正确（UTF-8）
- [ ] SEO标签完整
- [ ] 相关链接有效
- [ ] 响应式布局正常
- [ ] 浏览器预览无错误

---

## 📞 技术支持

如遇到问题：
1. 查看`templates/README-模板系统说明.md`
2. 查看`template-variables.json`中的变量定义
3. 参考现有文章的HTML结构（如`public/zh/深度研究.html`）

---

**文档版本**: 1.0  
**创建日期**: 2026年3月4日  
**最后更新**: 2026年3月4日  
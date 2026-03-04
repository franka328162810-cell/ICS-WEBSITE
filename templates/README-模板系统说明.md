# 📋 ICS网站模板系统说明

**版本**: 1.0  
**更新日期**: 2026年3月4日

---

## 📁 目录结构

```
templates/
├── README-模板系统说明.md          # 本文档
├── daily-commentary-zh.html       # 每日热点评论中文模板
├── daily-commentary-en.html       # 每日热点评论英文模板
├── in-depth-research-zh.html      # 深度研究中文模板
├── in-depth-research-en.html      # 深度研究英文模板
└── template-variables.json        # 模板变量映射表
```

---

## 🎯 模板用途

这些模板文件是**固定的HTML结构文件**，用于：

1. **确保网站风格一致性** - 所有文章页面使用统一的布局和样式
2. **简化发布流程** - 发布脚本基于这些模板自动生成文章页面
3. **便于批量更新** - 修改模板后，重新发布即可应用到所有文章
4. **规范内容结构** - 确保每篇文章包含所有必需的ICS框架要素

---

## 🔧 模板变量说明

### 每日热点评论模板变量

模板中使用 `{{变量名}}` 标记的占位符会被发布脚本替换为实际内容：

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `{{DATE}}` | 发布日期 | 2026年3月4日 |
| `{{CATEGORY}}` | 分类标签 | AI治理 |
| `{{HEADLINE}}` | 新闻标题 | 特朗普封杀Anthropic |
| `{{SOURCE}}` | 新闻来源 | 来源：综合报道 |
| `{{SOURCE_TIME}}` | 来源时间 | 2026年3月4日 14:00 |
| `{{SUMMARY}}` | 新闻摘要 | 美国国防部将Anthropic列为... |
| `{{NEW_THREE_VIEWS}}` | 新三观分析 | 从新宇宙观的参与性命题... |
| `{{NORMATIVE}}` | 规范性分析 | 从递归自由原则（RFP）... |
| `{{LONG_TERM_IMPACT}}` | 长期影响 | 在代际尺度上... |
| `{{REFLECTION_Q1}}` | 思考问题1 | 从递归自由度框架... |
| `{{REFLECTION_Q2}}` | 思考问题2 | 假设2125年的史学家... |
| `{{TAGS}}` | 标签列表 | 星际文明学, AI治理, RFP |

### 深度研究模板变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `{{PUBLICATION_WEEK}}` | 发布周次 | 2026年3月 第1周 |
| `{{TITLE}}` | 研究标题 | 特朗普封杀Anthropic：AI伦理红线... |
| `{{AUTHOR}}` | 作者 | 星际文明学研究所研究团队 |
| `{{ABSTRACT}}` | 摘要 | 美国国防部采取了史无前例的... |
| `{{KEYWORDS}}` | 关键词 | AI治理, 军事伦理, RFP, REV |
| `{{MAIN_SECTION_1_TITLE}}` | 第一部分标题 | 一、新闻事实 |
| `{{MAIN_SECTION_1_CONTENT}}` | 第一部分内容 | 美国总统特朗普签署... |
| `{{MAIN_SECTION_2_TITLE}}` | 第二部分标题 | 二、ICS视角分析 |
| `{{MAIN_SECTION_2_CONTENT}}` | 第二部分内容 | 从新三观视角... |
| `{{MAIN_SECTION_3_TITLE}}` | 第三部分标题 | 三、ICS六大指标概念估算 |
| `{{MAIN_SECTION_3_CONTENT}}` | 第三部分内容 | 以下所有指标均为... |
| `{{CONCLUSION_TITLE}}` | 结论标题 | 前进之路 |
| `{{CONCLUSION_CONTENT}}` | 结论内容 | 这一文明级伦理临界点... |
| `{{RECOMMENDATIONS}}` | 建议列表 | 建立强调可逆性的... |
| `{{RELATED_TOPICS}}` | 相关主题 | 军事伦理, 自主武器系统 |
| `{{CITATION_KEY}}` | 引用密钥 | ICS2026-TrumpAnthropic-001 |
| `{{ACKNOWLEDGMENTS}}` | 致谢 | 本研究受益于... |

---

## 🚀 使用方法

### 方法一：使用发布脚本（推荐）

发布脚本会自动读取模板并替换变量：

```powershell
# 每日热点评论
.\scripts\publish-daily-v4-seo.ps1 -ContentFile daily-20260304.json

# 深度研究
.\scripts\publish-research-v4-seo.ps1 -ContentFile in-depth-research-Week1-2026.json
```

### 方法二：手动使用模板

1. 复制对应的模板文件到工作目录
2. 用文本编辑器打开
3. 搜索 `{{` 找到所有变量占位符
4. 手动替换为实际内容
5. 保存为目标HTML文件

---

## 🎨 模板结构说明

### 通用结构

所有模板都包含以下标准结构：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <!-- 元数据：标题、描述、字体 -->
    <!-- CSS样式：全局尺寸、导航栏、内容区 -->
    <!-- SEO模块：Open Graph、Schema.org -->
</head>
<body>
    <!-- 导航栏 -->
    <nav class="navbar">...</nav>
    
    <!-- Hero区域：页面标题和引言 -->
    <div class="page-hero">...</div>
    
    <!-- 主内容区 -->
    <main class="main-content">
        <!-- 文章元数据：日期、分类、操作按钮 -->
        <!-- 各个章节内容 -->
    </main>
    
    <!-- Footer -->
    <footer class="footer">...</footer>
    
    <!-- JavaScript脚本 -->
</body>
</html>
```

### 每日热点评论特有结构

- 新闻摘要卡片
- 新三观分析section
- 规范性分析section
- 长期影响section
- 思考问题section
- 标签展示

### 深度研究特有结构

- 执行摘要section
- 三个主要部分（可扩展）
- ICS六大指标section
- 深时视角section
- 政策建议section
- 思考问题section
- ICS框架核查表
- 相关研究推荐

---

## ⚙️ 模板维护指南

### 何时需要更新模板？

1. **网站全局样式调整** - 字体、颜色、间距等
2. **增加新的ICS框架要素** - 如新增指标或原则
3. **SEO优化需求** - 调整元标签或结构化数据
4. **用户体验改进** - 布局优化、交互增强
5. **浏览器兼容性修复** - CSS或JavaScript调整

### 更新流程

1. **修改模板文件** - 在 `templates/` 目录中编辑
2. **测试验证** - 使用测试JSON文件生成预览
3. **更新说明文档** - 记录变更内容
4. **重新发布文章**（可选）- 如需应用到已发布文章

### 注意事项

⚠️ **重要提示**：

- 修改模板时保持变量占位符格式 `{{变量名}}`
- 不要删除必需的SEO标签和结构化数据
- 保持中英文模板结构一致性
- 修改后务必测试发布脚本是否正常工作

---

## 📊 ICS框架要素检查清单

每个模板都应包含以下ICS框架必需要素：

### 每日热点评论必需要素

- [ ] 新闻事实描述
- [ ] 新三观分析（NC-3, NL-2, NK-3）
- [ ] 规范原则分析（RFP, NRP, REV）
- [ ] 长期影响分析（T2-T3时间尺度）
- [ ] 思考问题（至少2个）
- [ ] 标签分类

### 深度研究必需要素

- [ ] 执行摘要
- [ ] 新三观分析
- [ ] 规范原则分析
- [ ] 禁忌红线检查（FRL）
- [ ] ICS六大指标（RFD, CRV, MBCL, CSIA, CDI, UCS）
- [ ] 深时视角（T2-T3）
- [ ] 政策建议（T1-T3层级）
- [ ] 思考问题（至少3个，覆盖事实/规范/深时层）
- [ ] ICS框架核查表
- [ ] 免责声明

---

## 🔗 相关文档

- [快速开始指南](../scripts/快速开始.md)
- [每日评论填写指南](../scripts/填写指南.md)
- [深度研究填写指南](../scripts/in-depth-research-填写指南.md)
- [发布系统文档](../README_Publishing_System.md)

---

## 📞 技术支持

如有模板使用问题或改进建议，请联系：
- 邮箱：franka328162810@gmail.com
- 项目仓库：提交Issue

---

**最后更新**: 2026年3月4日  
**维护者**: ICS技术团队

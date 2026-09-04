# 🚀 立即开始使用 - ICS Daily Commentary Publishing System

**⏱️ 预期时间**: 5分钟  
**📋 难度**: ⭐ 非常简单  
**👤 适合**: 任何人，无需技术背景

---

## 3个简单步骤

### ✋ 第1步: 复制模板文件

打开PowerShell，运行：

```powershell
cd c:\Users\Administrator\Documents\ics-website\scripts

# 复制模板，使用今天的日期
Copy-Item daily-commentary.sample.json daily-commentary-20250304.json
```

### 📝 第2步: 编辑JSON文件

用任何文本编辑器打开刚创建的文件：

```
scripts/daily-commentary-20250304.json
```

**需要填写的内容**（两个部分：EN + ZH）：

```json
{
  "en": {
    "date": "March 4, 2025",                    // 发布日期
    "category": "AI & Ethics",                  // 新闻分类
    "headline": "Breaking headline here...",    // 新闻标题
    "source": "News Source",                    // 新闻来源
    "sourceTime": "2025-03-04T09:00:00Z",      // 来源发布时间
    "summary": "Brief summary of the news...",   // 新闻摘要
    "newThreeViews": "Analysis using ICS framework...",  // 新三观分析
    "normative": "Evaluation using RFP/NRP/REV...",      // 规范原则
    "longTermImpact": "Long-term consequences...",        // 长期影响
    "reflectionQ1": "Reflection question 1?",            // 思考问题1
    "reflectionQ2": "Reflection question 2?",            // 思考问题2
    "tags": ["AI", "Ethics", "Future", "Governance"]     // 标签（5-7个）
  },
  "zh": {
    // 中文版本，字段相同，内容为中文
    "date": "2025年3月4日",
    "category": "人工智能与伦理",
    // ...其他字段
  }
}
```

✅ **小贴士**: 看`daily-commentary.sample.json`中的示例来了解每个字段的内容

### 🚀 第3步: 一键发布

回到PowerShell，运行：

```powershell
# 测试发布（不上传到网络）
.\publish-daily-commentary-v3.ps1 -ContentFile daily-commentary-20250304.json

# 或者直接正式发布（上传到网络）
.\publish-daily-commentary-v3.ps1 -ContentFile daily-commentary-20250304.json -Deploy
```

---

## ✨ 就这样！

一秒内：
- ✅ 英文版自动发布
- ✅ 中文版自动发布  
- ✅ 历史自动备份
- ✅ 归档自动更新
- ✅ git自动提交（如果用-Deploy）

---

## 🎯 立即体验

### 快速演示（有示例内容）

```powershell
cd c:\Users\Administrator\Documents\ics-website

# 这将生成一个包含示例新闻的JSON文件
.\scripts\demo-publishing.ps1 -GenerateOnly

# 然后执行演示发布
.\scripts\demo-publishing.ps1
```

---

## 📖 需要帮助？

| 需要 | 查看文件 | 用时 |
|------|---------|------|
| 快速开始 | `scripts/快速开始.md` | 5分钟 |
| 字段说明 | `scripts/填写指南.md` | 20分钟 |
| 完整技术文档 | `README_Publishing_System.md` | 1小时 |
| 实际示例 | `scripts/daily-commentary.sample.json` | 查看即可 |

---

## 🎁 您会得到

发布后，系统自动生成：

- 📄 **当日英文页**: `public/en/daily-commentary.html`
- 📄 **当日中文页**: `public/zh/每日热点评论.html`
- 💾 **英文备份**: `public/en/news/news-daily-20250304.html`
- 💾 **中文备份**: `public/zh/news/news-daily-20250304.html`
- 📚 **英文归档**: `public/en/news-archive.html` (自动更新，含所有历史)
- 📚 **中文归档**: `public/zh/每日热点评论归档.html` (自动更新，含所有历史)

---

## ❓ 常见问题

**Q: 我没有技术背景，能用吗？**  
A: 完全可以！只需要：
- 打开PowerShell（Windows自带）
- 编辑JSON文件（用记事本即可）
- 运行一条命令

**Q: 如果我填错了怎么办？**  
A: 没问题！重新编辑JSON文件，再运行脚本即可。所有旧版本都自动保存。

**Q: 中文字符会不会出问题？**  
A: 完全支持！系统自动处理UTF-8编码。

**Q: -Deploy是什么意思？**  
A: 它告诉脚本自动上传到网络（git）。不加这个标志只是本地测试。

**Q: 每天都要重复这3步吗？**  
A: 是的，但可以写成批处理脚本自动化。

---

## 🎉 开始吧！

现在您已经完全了解了：

```
1️⃣  Copy-Item daily-commentary.sample.json daily-commentary-20250304.json
2️⃣  # 编辑 daily-commentary-20250304.json，填入今天的内容
3️⃣  .\publish-daily-commentary-v3.ps1 -ContentFile daily-commentary-20250304.json -Deploy
```

**Just 3 lines, Done!** ✨

---

**准备好了吗？前往 `scripts/` 目录开始！** 🚀

*Last Updated: 2025-03-04*
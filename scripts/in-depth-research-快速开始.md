# 📚 ICS In-Depth Research 发布系统 - 快速开始指南

## 概述

**完全自动化的学术研究中英文双语发布系统** ✨

- 🔄 **一次填写，双语同步发布**（英文 + 中文）
- 📦 **自动备份每周研究**（每周自动保存，永不丢失）
- 📚 **自动生成研究归档**（访客可浏览所有历史研究）
- 🚀 **一键部署**（git自动提交推送）

---

## 文件说明

### 📁 核心文件

| 文件 | 位置 | 用途 |
|------|------|------|
| **in-depth-research.sample.json** | `scripts/` | 内容填写模板 |
| **publish-in-depth-research-v3.ps1** | `scripts/` | 发布脚本（v3版本） |
| **in-depth-research.html** | `public/en/` | 英文当周页面 |
| **深度研究.html** | `public/zh/` | 中文当周页面 |
| **research-archive.html** | `public/en/` | 英文研究归档索引（自动生成） |
| **研究归档.html** | `public/zh/` | 中文研究归档索引（自动生成） |

### 📝 历史文件（自动生成）

```
public/en/articles/research-Week1-March2026-en.html    # 英文归档
public/zh/articles/research-Week1-March2026-zh.html    # 中文归档
public/en/articles/research-Week2-March2026-en.html    # 下周存档
...
```

---

## 🚀 快速开始 - 3个步骤

### 步骤 1️⃣  复制和命名模板

```powershell
# 进入脚本目录
cd c:\Users\Administrator\Documents\ics-website\scripts

# 复制模板文件，使用本周的标识命名
Copy-Item in-depth-research.sample.json in-depth-research-Week1-March2026.json
```

### 步骤 2️⃣  填写内容

用编辑器打开 `in-depth-research-Week1-March2026.json`，填入本周的研究内容：

```json
{
  "en": {
    "publicationWeek": "Week 1, March 2026",
    "title": "Research Title Here",
    "author": "ICS Research Team",
    "abstract": "Brief abstract of the research (3-5 sentences)",
    "keywords": ["Keyword1", "Keyword2", "Keyword3"],
    "mainSection1Title": "First Section Title",
    "mainSection1Content": "Content of first section (can be multiple paragraphs)",
    "mainSection2Title": "Second Section Title",
    "mainSection2Content": "Content of second section",
    "mainSection3Title": "Third Section Title",
    "mainSection3Content": "Content of third section with conclusions",
    "conclusionTitle": "Conclusion",
    "conclusionContent": "Final thoughts and implications",
    "recommendations": [
      "Recommendation 1",
      "Recommendation 2",
      "Recommendation 3"
    ],
    "relatedTopics": ["Topic1", "Topic2", "Topic3"],
    "citationKey": "ICS2026-Topic-001",
    "acknowledgments": "Funding and support acknowledgments"
  },
  "zh": {
    // 中文版本，字段相同，内容为中文
    "publicationWeek": "2026年3月 第1周",
    "title": "研究标题",
    // ...其他字段
  }
}
```

### 步骤 3️⃣  发布

#### 测试发布（不部署到网络）
```powershell
.\publish-in-depth-research-v3.ps1 -ContentFile in-depth-research-Week1-March2026.json
```

#### 正式发布（部署到网络）
```powershell
.\publish-in-depth-research-v3.ps1 -ContentFile in-depth-research-Week1-March2026.json -Deploy
```

---

## 📊 流程图

```
┌──────────────────────────────────┐
│  in-depth-research-Week-*.json   │ ← 填写本周研究
└────────────┬─────────────────────┘
             │
             ↓
┌──────────────────────────────────────┐
│  publish-in-depth-research-v3.ps1    │
│  PowerShell发布脚本                   │
└────────────┬────────────────────────┘
             │
     ┌───────┼───────┐
     ↓       ↓       ↓
   [备份]  [更新]  [生成]
     │       │       │
     ↓       ↓       ↓
 research  en/     归档
 -Week-*   zh/     索引

[Step 1] 💾 备份上周的研究
         → public/en/articles/research-Week-*-en.html
         → public/zh/articles/research-Week-*-zh.html

[Step 2] 📝 更新当周页面
         → public/en/in-depth-research.html（新内容）
         → public/zh/深度研究.html（新内容）

[Step 3] 📚 生成/更新研究归档索引
         → public/en/research-archive.html（完整研究列表）
         → public/zh/研究归档.html（完整研究列表）

[Step 4] 🚀 git部署（可选）
         → git add + commit + push
```

---

## 💡 内容填写要点

### 必填字段（13个）

| 字段 | 含义 | 示例 |
|------|------|------|
| **publicationWeek** | 发布周次 | "Week 1, March 2026" (EN) / "2026年3月 第1周" (ZH) |
| **title** | 研究标题 | "The Recursive Nature of Existential Risk..." |
| **author** | 作者 | "ICS Research Team" |
| **abstract** | 摘要 | 3-5句话概括研究 |
| **keywords** | 关键词 | 5-7个相关关键词 |
| **mainSection1Title** | 第一部分标题 | "Introduction: ..." |
| **mainSection1Content** | 第一部分内容 | 详细内容段落 |
| **mainSection2Title** | 第二部分标题 | "Theoretical Framework: ..." |
| **mainSection2Content** | 第二部分内容 | 详细内容段落 |
| **mainSection3Title** | 第三部分标题 | "Key Findings: ..." |
| **mainSection3Content** | 第三部分内容 | 详细内容段落 |
| **conclusionTitle** | 结论标题 | "Pathways Forward" |
| **conclusionContent** | 结论内容 | 总结与启示 |
| **recommendations** | 建议列表 | 4-6条具体建议 |
| **relatedTopics** | 相关话题 | 3-4个相关主题 |
| **citationKey** | 引用密钥 | "ICS2026-Topic-001" |
| **acknowledgments** | 致谢 | 资助机构及支持 |

### 质量检查清单 ✅

- [ ] 周次标识清晰
- [ ] 标题准确有意义
- [ ] 摘要客观准确
- [ ] 三个主要部分逻辑连贯
- [ ] 关键词5-7个
- [ ] 建议具体可行
- [ ] 引用密钥格式一致
- [ ] 没有打字错误
- [ ] JSON格式有效

---

## 🔍 验证

发布后检查：

```
✅ public/en/in-depth-research.html - 英文页面已更新
✅ public/zh/深度研究.html - 中文页面已更新
✅ public/en/articles/research-Week-*.html - 历史备份已创建
✅ public/zh/articles/research-Week-*.html - 历史备份已创建
✅ public/en/research-archive.html - 英文归档已更新
✅ public/zh/研究归档.html - 中文归档已更新
✅ git 日志显示新的提交（如果用了-Deploy）
```

---

## 🛠️ 常见问题

### Q: 如何选择publicationWeek?
**A:** 根据发布时间选择，格式为：
- EN: "Week N, Month Year" (例: "Week 1, March 2026")
- ZH: "Year年Month月 第N周" (例: "2026年3月 第1周")

### Q: mainSectionContent可以很长吗？
**A:** 完全可以。系统支持多段落内容。建议保持200-500字范围以保持可读性。

### Q: 如何修改已发布的研究？
**A:** 重新编辑JSON文件，再次运行发布脚本即可。所有旧版本都保存在articles目录中。

### Q: recommendations和relatedTopics的区别？
**A:** 
- **recommendations**: 针对本研究的具体建议或后续行动
- **relatedTopics**: 相关的研究领域或话题，便于发现相关内容

### Q: citationKey如何格式化？
**A:** 建议格式: `ICS[YEAR]-[TOPIC]-[NUMBER]`
- 例: `ICS2026-ExistentialRisk-001`, `ICS2026-AIGovernance-002`

---

## 📈 系统架构

```
[Weekly Input]
      ↓
   JSON格式
      ↓
[PowerShell脚本]
      ├→ Archive-PreviousResearch()
      │  └→ research-Week-*.html
      ├→ Replace-ByPattern()
      │  └→ Update HTML pages
      ├→ Join-List()
      │  └→ Format lists (recommendations, keywords)
      └→ Update-ResearchArchiveIndex()
         └→ Generate archive index
      ↓
[Dual Output]
  ├→ public/en/in-depth-research.html
  ├→ public/zh/深度研究.html
  ├→ public/en/articles/research-Week-*-en.html
  ├→ public/zh/articles/research-Week-*-zh.html
  ├→ public/en/research-archive.html
  └→ public/zh/研究归档.html
      ↓
[Git Deployment] (optional with -Deploy)
```

---

## 🎯 下一步

1. **准备本周研究**：整理研究内容和结论
2. **第一次发布**：按步骤操作
3. **观察效果**：访问网站确认内容正确显示
4. **建立习惯**：每周同一时间发布研究

---

## 📞 技术支持

- 脚本路径：`scripts/publish-in-depth-research-v3.ps1`
- 模板示例：`scripts/in-depth-research.sample.json`
- 参考指南：见本文件

---

*Last Updated: 2026-03-04*
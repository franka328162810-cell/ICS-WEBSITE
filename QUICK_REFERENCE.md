
# 📋 ICS Publishing System - Quick Reference Card

**打印这张卡，贴在办公桌上！**

---

## 🎯 Daily Publishing in 3 Commands

```powershell
# 1. Create today's file
Copy-Item scripts\daily-commentary.sample.json `
         scripts\daily-commentary-$(Get-Date -Format 'yyyyMMdd').json

# 2. Edit the file
notepad scripts\daily-commentary-$(Get-Date -Format 'yyyyMMdd').json

# 3. Publish!
.\scripts\publish-daily-commentary-v3.ps1 `
  -ContentFile scripts\daily-commentary-$(Get-Date -Format 'yyyyMMdd').json `
  -Deploy
```

---

## 📝 JSON Structure (Copy & Fill)

```json
{
  "en": {
    "date": "March 4, 2025",
    "category": "Category Name",
    "headline": "News Headline",
    "source": "Source Name",
    "sourceTime": "2025-03-04T09:00:00Z",
    "summary": "Paragraph summarizing the news",
    "newThreeViews": "Analysis of new views",
    "normative": "Normative principle analysis",
    "longTermImpact": "Long-term impacts",
    "reflectionQ1": "Question 1?",
    "reflectionQ2": "Question 2?",
    "tags": ["Tag1", "Tag2", "Tag3"]
  },
  "zh": {
    "date": "2025年3月4日",
    "category": "分类",
    "headline": "新闻标题",
    ...same structure...
  }
}
```

---

## ✅ Pre-Publishing Checklist

- [ ] JSON file created
- [ ] All 12 fields filled (EN)
- [ ] All 12 fields filled (ZH)
- [ ] Dates formatted correctly
- [ ] No unclosed quotes
- [ ] Headlines under 100 chars
- [ ] Tags 5-7 items each
- [ ] File saved as UTF-8

---

## 🎬 Demo/Test Commands

```powershell
# Generate sample content
.\scripts\demo-publishing.ps1 -GenerateOnly

# Test publish (no deployment)
.\scripts\publish-daily-commentary-v3.ps1 `
  -ContentFile daily-commentary-20250304.json

# Full publish with deployment
.\scripts\publish-daily-commentary-v3.ps1 `
  -ContentFile daily-commentary-20250304.json `
  -Deploy
```

---

## 📚 Field Definitions (Quick)

| Field | What to Include | Example |
|-------|-----------------|---------|
| date | Publication date | "March 4, 2025" |
| category | News category | "AI Ethics" |
| headline | Main headline | "New AI Breakthrough..." |
| source | Where it's from | "Nature, Reuters" |
| sourceTime | When reported | "2025-03-04T09:00:00Z" |
| summary | 3-5 sentence summary | "Researchers announced..." |
| newThreeViews | ICS framework analysis | Use new views concepts |
| normative | Principle evaluation | RFP/NRP/REV references |
| longTermImpact | 100-1000 year impact | Think long-term |
| reflectionQ1 | First question | Open-ended question |
| reflectionQ2 | Second question | Another question |
| tags | Keyword tags | 5-7 relevant tags |

---

## 🗂️ File Locations

```
scripts/
  ├── daily-commentary.sample.json    ← Template (copy this)
  ├── publish-daily-commentary-v3.ps1 ← Main script
  ├── 快速开始.md                     ← Quick guide
  ├── 填写指南.md                     ← Detailed guide
  └── demo-publishing.ps1             ← Demo script

public/
  ├── en/
  │   ├── daily-commentary.html       ← Today's EN page
  │   ├── news-archive.html           ← EN history
  │   └── news/                       ← Backups here
  └── zh/
      ├── 每日热点评论.html           ← Today's ZH page
      ├── 每日热点评论归档.html       ← ZH history
      └── news/                       ← Backups here
```

---

## 🔧 Troubleshooting

| Problem | Solution |
|---------|----------|
| "JSON parse error" | Check JSON syntax, copy from sample |
| "File not found" | Run from correct directory |
| "Git not found" | Don't use -Deploy, or init git |
| "Permission denied" | Run PowerShell as admin |
| Special chars broken | They're auto-escaped, use normal text |

---

## 💾 Backup Naming

Automatic backups created as:
```
news-daily-20250304.html  ← This year's March 4
news-daily-20250303.html  ← Previous day
news-daily-20250302.html  ← Day before...
```

All stored in `public/en/news/` and `public/zh/news/`

---

## ⚡ One-Liner Quick Publish

```powershell
$d=$(Get-Date -Format 'yyyyMMdd');cp scripts\daily-commentary.sample.json scripts\daily-commentary-$d.json;.\scripts\publish-daily-commentary-v3.ps1 -ContentFile scripts\daily-commentary-$d.json -Deploy
```

(Not recommended unless you know what you're doing)

---

## 📖 Documentation Map

```
GET_STARTED_NOW.md                    ← You are here (5 min)
  ↓
scripts/快速开始.md                   ← (10 min)
  ↓
scripts/填写指南.md                   ← (30 min)
  ↓
README_Publishing_System.md           ← (1 hour)
  ↓
publish-daily-commentary-v3.ps1       ← Source code
```

---

## 🎯 Key Principles

✨ **One JSON, Two Languages**
- Write once, publish both

💾 **Auto-Archive**
- Every day saved automatically

📚 **Browseable History**
- Visitors can see all past commentaries

🚀 **One-Click Deploy**
- Auto-commit to git with -Deploy

🛡️ **Safe & Reversible**
- All changes in version control

---

## 📞 Need Help?

1. Check `GET_STARTED_NOW.md` (basic)
2. Read `scripts/快速开始.md` (step-by-step)
3. Reference `scripts/填写指南.md` (field details)
4. Study `README_Publishing_System.md` (technical)
5. Copy from `daily-commentary.sample.json` (examples)

---

## 🎉 Remember

**The goal**: Automate your bilingual publishing workflow  
**The method**: Fill JSON → Run script → Done  
**The result**: Both languages live + Full history preserved

---

**Status**: ✅ Ready to Use  
**Version**: 3.0  
**Updated**: 2025-03-04

**Good luck! 🚀**
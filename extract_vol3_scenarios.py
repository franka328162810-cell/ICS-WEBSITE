"""Extract key tables from Ch23-26 scenarios and the Conclusion from Vol 3."""
import docx, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

doc = docx.Document(r'C:\Users\Administrator\Desktop\《星际文明的规范性基础：新三观与深不确定性下的治理》\9.0书籍提交\2025-1-25第三卷定稿.docx')
paras = doc.paragraphs

out = []

def add(s):
    out.append(s)

# ============================================================
# Ch23 AGI - framework component applicability table (around para 4451)
# Ch24 FC - framework component applicability table (around para 7079)
# Ch25 ECO - framework component applicability table (around para 9417)
# Ch26 IG - framework component applicability table (around para 11859)
# ============================================================

# Extract key sections from each scenario chapter
scenario_ranges = [
    ("Ch23 AGI突破", 3576, 5637, [
        (4440, 4520, "框架组件适用性评分表"),
        (5580, 5637, "本章小结核心结论"),
    ]),
    ("Ch24 First Contact", 6212, 8048, [
        (7060, 7140, "框架组件适用性评分表"),
        (7980, 8048, "本章小结核心结论"),
    ]),
    ("Ch25 生态临界点", 8694, 10425, [
        (9400, 9480, "框架组件紧急适用性评分表"),
        (10360, 10425, "本章小结核心结论"),
    ]),
    ("Ch26 代际正义危机", 11195, 12902, [
        (11840, 11920, "框架组件代际适用性评分表"),
        (12840, 12902, "本章小结核心结论"),
    ]),
]

for chap_name, ch_start, ch_end, sections in scenario_ranges:
    add("=" * 80)
    add(f"{chap_name}")
    add("=" * 80)
    
    for sec_start, sec_end, sec_name in sections:
        add(f"\n--- {sec_name} (para {sec_start}-{sec_end}) ---")
        for i in range(sec_start, min(sec_end + 1, len(paras))):
            text = paras[i].text.strip()
            if not text:
                continue
            is_bold = any(run.bold for run in paras[i].runs if run.text.strip())
            prefix = "[B] " if is_bold else ""
            add(f"{prefix}[{i}] {text}")

# ============================================================
# Also extract the conclusions from each scenario chapter
# Look for "本章小结" or "核心结论" sections near the end of each chapter
# ============================================================

# Extract broader conclusion sections
for chap_name, look_start, look_end in [
    ("Ch23 AGI - 结论", 5500, 5637),
    ("Ch24 FC - 结论", 7900, 8048),
    ("Ch25 ECO - 结论", 10300, 10425),
    ("Ch26 IG - 结论", 12770, 12902),
]:
    add(f"\n{'=' * 80}")
    add(f"{chap_name}")
    add("=" * 80)
    for i in range(look_start, min(look_end + 1, len(paras))):
        text = paras[i].text.strip()
        if not text:
            continue
        is_bold = any(run.bold for run in paras[i].runs if run.text.strip())
        prefix = "[B] " if is_bold else ""
        add(f"{prefix}[{i}] {text}")

# ============================================================
# Extract 结语 (Conclusion) - starts around para 35043
# ============================================================
add(f"\n{'=' * 80}")
add("结语 总结与展望")
add("=" * 80)

# Key parts of conclusion: summary tables, limitations matrix, overall assessment
for i in range(35043, min(35862, len(paras))):
    text = paras[i].text.strip()
    if not text:
        continue
    is_bold = any(run.bold for run in paras[i].runs if run.text.strip())
    prefix = "[B] " if is_bold else ""
    add(f"{prefix}[{i}] {text}")

content = '\n'.join(out)
with open(r'c:\Users\Administrator\Documents\ics-website\vol3_scenarios_conclusion.txt', 'w', encoding='utf-8') as f:
    f.write(content)

print(f"Extracted {len(out)} lines")
print(f"File size: {len(content)} chars")

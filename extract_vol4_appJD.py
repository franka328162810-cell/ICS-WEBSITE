"""Extract Appendix J (Minimal Argument Path) + Appendix D key protocol rules from Volume 4."""
import docx, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

doc = docx.Document(r'C:\Users\Administrator\Desktop\《星际文明的规范性基础：新三观与深不确定性下的治理》\9.0书籍提交\2025-1-25第四卷（附录卷）定稿.docx')
paras = doc.paragraphs

output = []

# === Appendix J: paragraphs 23272 to ~24505 ===
output.append("=" * 70)
output.append("APPENDIX J: MINIMAL ARGUMENT PATH (最小论证路径)")
output.append("=" * 70)

for i in range(23272, min(24700, len(paras))):
    text = paras[i].text.strip()
    if not text:
        continue
    is_bold = any(run.bold for run in paras[i].runs if run.text.strip())
    if is_bold:
        output.append(f"\n[B] {text}")
    else:
        output.append(text)

# === Appendix D key sections: Protocol Stack structure ===
output.append("\n\n" + "=" * 70)
output.append("APPENDIX D KEY: PROTOCOL STACK RULES (协议栈规则关键部分)")
output.append("=" * 70)

# D.1 总则 + D.2 L0 + D.3 L1 + D.4 L2 (principles/FRL rules) - para 11625 to ~12200
# Focus on D.4 (L2 normative principle rules) and D.4.4 (FRL rules)
for i in range(11625, min(12200, len(paras))):
    text = paras[i].text.strip()
    if not text:
        continue
    is_bold = any(run.bold for run in paras[i].runs if run.text.strip())
    if is_bold:
        output.append(f"\n[B] {text}")
    else:
        output.append(text)

# D.4.4 FRL rules specifically - scan for this section
output.append("\n\n--- D.4.4 FRL RULES (禁忌红线规则) ---")
in_frl = False
for i in range(12200, min(13602, len(paras))):
    text = paras[i].text.strip()
    if not text:
        continue
    if '禁忌红线' in text or 'D.4.4' in text:
        in_frl = True
    if in_frl:
        is_bold = any(run.bold for run in paras[i].runs if run.text.strip())
        if is_bold:
            output.append(f"\n[B] {text}")
        else:
            output.append(text)
    # Stop at D.5
    if in_frl and ('D.5' in text and '层规则' in text):
        break

result = '\n'.join(output)
with open(r'c:\Users\Administrator\Documents\ics-website\vol4_appendixJD_raw.txt', 'w', encoding='utf-8') as f:
    f.write(result)

print(f"Appendix J+D extracted: {len(output)} lines, {len(result):,} chars")

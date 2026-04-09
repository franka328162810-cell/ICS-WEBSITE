"""Extract Appendix C (Indicator Calculation Guide) key formulas and weights from Volume 4."""
import docx, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

doc = docx.Document(r'C:\Users\Administrator\Desktop\《星际文明的规范性基础：新三观与深不确定性下的治理》\9.0书籍提交\2025-1-25第四卷（附录卷）定稿.docx')
paras = doc.paragraphs

# Appendix C: paragraphs 8941 to 11625
output = []
output.append("=" * 70)
output.append("APPENDIX C: INDICATOR CALCULATION GUIDE (指标计算指南)")
output.append("=" * 70)

for i in range(8941, min(11625, len(paras))):
    text = paras[i].text.strip()
    if not text:
        continue
    is_bold = any(run.bold for run in paras[i].runs if run.text.strip())
    if is_bold:
        output.append(f"\n[B] {text}")
    else:
        output.append(text)

result = '\n'.join(output)
with open(r'c:\Users\Administrator\Documents\ics-website\vol4_appendixC_raw.txt', 'w', encoding='utf-8') as f:
    f.write(result)

print(f"Appendix C extracted: {len(output)} lines, {len(result):,} chars")

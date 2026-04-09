"""Extract Appendix A (Core Glossary) key terms with definitions from Volume 4."""
import docx, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

doc = docx.Document(r'C:\Users\Administrator\Desktop\《星际文明的规范性基础：新三观与深不确定性下的治理》\9.0书籍提交\2025-1-25第四卷（附录卷）定稿.docx')
paras = doc.paragraphs

# Appendix A: paragraphs 1662 to 4924
# We need key term definitions - look for definition patterns
# The glossary has sections: A.1 本体论, A.2 认识论, A.3 规范性, A.4 指标, A.5 制度

output = []
output.append("=" * 70)
output.append("APPENDIX A: CORE GLOSSARY (核心术语表)")
output.append("=" * 70)

# Extract all content from Appendix A (para 1662 to 4924)
for i in range(1662, min(4924, len(paras))):
    text = paras[i].text.strip()
    if not text:
        continue
    is_bold = any(run.bold for run in paras[i].runs if run.text.strip())
    if is_bold:
        output.append(f"\n[B] {text}")
    else:
        output.append(text)

result = '\n'.join(output)
with open(r'c:\Users\Administrator\Documents\ics-website\vol4_appendixA_raw.txt', 'w', encoding='utf-8') as f:
    f.write(result)

print(f"Appendix A extracted: {len(output)} lines, {len(result):,} chars")

"""Extract basic info and TOC from Volume 4 (Appendix Volume)."""
import docx, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

doc = docx.Document(r'C:\Users\Administrator\Desktop\《星际文明的规范性基础：新三观与深不确定性下的治理》\9.0书籍提交\2025-1-25第四卷（附录卷）定稿.docx')
paras = doc.paragraphs

print(f"Total paragraphs: {len(paras)}")

# Count total chars
total_chars = sum(len(p.text) for p in paras)
print(f"Total chars: {total_chars:,}")

# Print first 300 non-empty paragraphs to get TOC and structure
print("\n=== FIRST 300 NON-EMPTY PARAGRAPHS ===")
count = 0
for i, p in enumerate(paras):
    text = p.text.strip()
    if text:
        is_bold = any(run.bold for run in p.runs if run.text.strip())
        prefix = "[B] " if is_bold else ""
        print(f"{prefix}[{i}] {text[:200]}")
        count += 1
        if count >= 300:
            break

# Also scan for key appendix markers
print("\n\n=== KEY APPENDIX MARKERS (scanning all paragraphs) ===")
markers = ['附录A', '附录B', '附录C', '附录D', '附录E', '附录F', '附录G', '附录H', '附录I', '附录J',
           'Appendix A', 'Appendix B', 'Appendix C', 'Appendix D', 'Appendix E', 'Appendix F',
           'Appendix G', 'Appendix H', 'Appendix I', 'Appendix J',
           '核心术语', '指标计算', '最小论证', '速查', '公式汇总', '关键术语']

for i, p in enumerate(paras):
    text = p.text.strip()
    if not text:
        continue
    for m in markers:
        if m in text:
            is_bold = any(run.bold for run in p.runs if run.text.strip())
            prefix = "[B] " if is_bold else ""
            print(f"{prefix}[{i}] {text[:250]}")
            break

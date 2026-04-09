import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
from docx import Document

path = r'C:\Users\Administrator\Desktop\《星际文明的规范性基础：新三观与深不确定性下的治理》\9.0书籍提交\2025-1-25第三卷定稿.docx'
doc = Document(path)
paras = doc.paragraphs

total_chars = sum(len(p.text) for p in paras)
print(f'Total paragraphs: {len(paras)}')
print(f'Total chars: {total_chars}')

# Print first 200 non-empty paragraphs to see TOC and structure
print('\n=== FIRST 200 NON-EMPTY PARAGRAPHS ===')
count = 0
for i, p in enumerate(paras):
    text = p.text.strip()
    if text:
        bold = any(r.bold for r in p.runs if r.bold)
        tag = '[B] ' if bold else '    '
        print(f'[{i}] {tag}{text[:150]}')
        count += 1
        if count >= 200:
            break

import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
from docx import Document

path = r'C:\Users\Administrator\Desktop\《星际文明的规范性基础：新三观与深不确定性下的治理》\9.0书籍提交\2025-1-25第二卷定稿.docx'
doc = Document(path)
paras = doc.paragraphs

# Find all appendix sections with quick ref cards and key terms
print('=== APPENDIX SECTIONS (速查/对照/概念) ===')
for i in range(1100, len(paras)):
    text = paras[i].text.strip()
    bold = any(r.bold for r in paras[i].runs if r.bold)
    if text and len(text) < 120:
        keywords = ['速查', '核心概念', '术语中英对照', '计算指南', '评估模板', 
                     '应用场景', '附录', '快速参考', '关键术语', '维度', '公式',
                     '评分', '打分', '赋值', '权重', '阈值', '量表']
        if any(k in text for k in keywords):
            tag = '[BOLD] ' if bold else ''
            print(f'[{i}] {tag}{text}')

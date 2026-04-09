import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
from docx import Document

path = r'C:\Users\Administrator\Desktop\《星际文明的规范性基础：新三观与深不确定性下的治理》\9.0书籍提交\2025-1-25第三卷定稿.docx'
doc = Document(path)
paras = doc.paragraphs

# Find all chapter starts and key sections
print('=== BOLD CHAPTER/SECTION HEADERS (after para 300) ===')
for i in range(300, len(paras)):
    text = paras[i].text.strip()
    if not text or len(text) > 200:
        continue
    bold = any(r.bold for r in paras[i].runs if r.bold)
    if bold and any(k in text for k in ['第二十', '第三十', '结语', '导言', '附录',
                                          '压力测试', '综合报告', '对话', '议程',
                                          '开放问题', '总结', '脚注', '参考文献',
                                          '速查', '核心概念', '关键术语', '术语中英',
                                          'Chapter', 'Part', '本卷']):
        print(f'[{i}] {text[:150]}')

print('\n=== KEY CONTENT MARKERS ===')
for i in range(300, len(paras)):
    text = paras[i].text.strip()
    if not text or len(text) > 200:
        continue
    if any(k in text for k in ['速查', '核心概念速查', '术语中英对照', '总览',
                                 '综合评估', '弱点汇总', '修订建议汇总',
                                 '压力测试结论', '整体评价', '框架表现',
                                 '建议优先级', '主要发现']):
        bold = any(r.bold for r in paras[i].runs if r.bold)
        tag = '[B] ' if bold else '    '
        print(f'[{i}] {tag}{text[:150]}')

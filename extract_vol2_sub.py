import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
from docx import Document

path = r'C:\Users\Administrator\Desktop\《星际文明的规范性基础：新三观与深不确定性下的治理》\9.0书籍提交\2025-1-25第二卷定稿.docx'
doc = Document(path)
paras = doc.paragraphs

def extract_range(start, end, label):
    lines = []
    lines.append(f'\n{"="*80}')
    lines.append(f'  {label}')
    lines.append(f'{"="*80}\n')
    for i in range(start, min(end, len(paras))):
        text = paras[i].text.strip()
        if text:
            bold = any(r.bold for r in paras[i].runs if r.bold)
            prefix = '[B] ' if bold else '    '
            lines.append(f'{prefix}{text}')
    return '\n'.join(lines)

output = []

# UCS D1 info integration sub-dimensions (para 4045-4180)
output.append(extract_range(4045, 4178, 'UCS D1信息整合度详细'))

# UCS D2 temporal depth sub-dimensions (para 4178-4280)
output.append(extract_range(4178, 4280, 'UCS D2时间深度详细'))

# UCS D3 reflexivity sub-dimensions (para 4280-4384)
output.append(extract_range(4280, 4384, 'UCS D3反身性详细'))

# UCS D4 value sensitivity sub-dimensions (para 4384-4484)
output.append(extract_range(4384, 4484, 'UCS D4价值敏感性详细'))

# UCS D5 sociality sub-dimensions (para 4484-4600)
output.append(extract_range(4484, 4600, 'UCS D5社会性详细'))

# CRV V_obs sub-dimensions (para 7160-7260)
output.append(extract_range(7160, 7260, 'CRV V_obs可观测性子维度'))

# CRV V_enf sub-dimensions (para 7260-7380)
output.append(extract_range(7260, 7380, 'CRV V_enf可执行性子维度'))

# CRV V_rev sub-dimensions (para 7380-7510)
output.append(extract_range(7380, 7510, 'CRV V_rev可回滚性子维度'))

# Ch6 indicator-principle mapping (para 1400-1500)
output.append(extract_range(1400, 1500, 'CH6 指标与原则映射'))

# Key terms - search around the end appendices
# Check for bilingual terms table in Ch6 footer area
output.append(extract_range(3250, 3340, 'CH6 章结论与术语'))

# MBCL four factors detailed (para 9580-9660)
output.append(extract_range(9580, 9660, 'MBCL四因素评估详细'))

# Write to file
with open(r'C:\Users\Administrator\Documents\ics-website\vol2_subdimensions.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(output))

print('Written to vol2_subdimensions.txt')
print(f'Total chars: {len(chr(10).join(output))}')

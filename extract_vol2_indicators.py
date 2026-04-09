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

# 1. Ch6 overview: indicator architecture (para 2198-2600) - 六大指标总论概览
output.append(extract_range(2198, 2600, 'CH6 六大指标概览 (§6.3)'))

# 2. Ch7 UCS five dimensions summary table (para 4595-4650)
output.append(extract_range(4595, 4660, 'CH7 UCS五维度总览表'))

# 3. UCS measurement and aggregation (para 4898-4960)
output.append(extract_range(4898, 4960, 'CH7 UCS聚合与权重'))

# 4. UCS moral consideration weight (para 5404-5520)
output.append(extract_range(5404, 5520, 'CH7 UCS道德考量权重'))

# 5. RFD core formula (para 6594-6670)
output.append(extract_range(6594, 6670, 'CH8 RFD核心公式'))

# 6. RFD proxy indicators (para 6840-6870)
output.append(extract_range(6840, 6870, 'CH8 RFD代理指标'))

# 7. CRV three dimensions (para 7080-7160)
output.append(extract_range(7080, 7160, 'CH8 CRV三维度结构'))

# 8. CRV aggregation and thresholds (para 7508-7570)
output.append(extract_range(7508, 7570, 'CH8 CRV聚合与阈值'))

# 9. CRV formula index (para 8439-8500)
output.append(extract_range(8439, 8500, 'CH8 核心公式索引'))

# 10. CDI five dimensions detailed (para 8826-8970)
output.append(extract_range(8826, 8970, 'CH9 CDI五维度详细'))

# 11. CDI aggregation (para 9119-9145)
output.append(extract_range(9119, 9145, 'CH9 CDI聚合评分'))

# 12. MBCL - need to find the section
# Search for MBCL content
output.append(extract_range(9340, 9420, 'CH9 MBCL概述'))

# 13. MBCL levels and scoring (para 9500-9700)
output.append(extract_range(9500, 9700, 'CH9 MBCL等级与评分'))

# 14. CSIA six dimensions (para 9939-10075)
output.append(extract_range(9939, 10075, 'CH9 CSIA六维度'))

# 15. CSIA scoring and risk levels (para 10118-10160)
output.append(extract_range(10118, 10160, 'CH9 CSIA综合评分与风险等级'))

# 16. Ch10 indicator comparison table (para 11410-11450)
output.append(extract_range(11410, 11450, 'CH10 六大指标结构比较'))

# 17. Chapter 6 indicator-principle mapping (para 2000-2100)
output.append(extract_range(2000, 2100, 'CH6 指标与原则的映射关系'))

# 18. Chapter 9 formula index
output.append(extract_range(10870, 10900, 'CH9 核心公式索引'))

# 19. CSIA detailed scoring tables from Ch19 (para 21176-21300)
output.append(extract_range(21176, 21300, 'CH19 CSIA六维度详细评分标准'))

# Write to file
with open(r'C:\Users\Administrator\Documents\ics-website\vol2_indicators.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(output))

print('Written to vol2_indicators.txt')
print(f'Total characters: {len(chr(10).join(output))}')

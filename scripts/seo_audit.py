import pathlib
import re
import csv
base = pathlib.Path('public')
files = sorted(base.rglob('*.html'))
out = []
patterns = {
    'Seo': re.compile(r'<!-- ICS-SEO-START -->'),
    'Canonical': re.compile(r'<link rel="canonical"'),
    'OpenGraph': re.compile(r'<meta property="og:'),
    'Twitter': re.compile(r'<meta name="twitter:'),
    'JsonLd': re.compile(r'<script type="application/ld\+json"')
}
for p in files:
    text = p.read_text(encoding='utf-8')
    row = {'Path': str(p)}
    for k, r in patterns.items():
        row[k] = bool(r.search(text))
    out.append(row)
with open('seo_audit.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['Path','Seo','Canonical','OpenGraph','Twitter','JsonLd'])
    writer.writeheader()
    writer.writerows(out)
print('DONE')

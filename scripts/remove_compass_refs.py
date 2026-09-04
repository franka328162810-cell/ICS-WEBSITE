#!/usr/bin/env python3
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TARGET_DIRS = [ROOT / 'public', ROOT / 'templates']

nav_link_re = re.compile(r"\s*<li>\s*<a\s+href=[\"']/compass/[\"'][^>]*>.*?</a>\s*</li>\s*", re.S)
# match .compass-cta { ... } blocks in <style> sections
css_block_re = re.compile(r"\.compass-cta\s*\{[\s\S]*?\}\s*", re.I)
# match <div class="compass-cta"> ... </div> (multiline)
html_cta_re = re.compile(r"<div[^>]*class=[\"'][^\"']*compass-cta[^\"']*[\"'][^>]*>[\s\S]*?<\/div>\s*", re.I)
# match anchor links that directly point to /compass/ in other contexts
href_compass_re = re.compile(r'href=["\"]/compass/["\"]')

changed_files = []
for base in TARGET_DIRS:
    if not base.exists():
        continue
    for p in base.rglob('*.html'):
        try:
            s = p.read_text(encoding='utf-8')
        except Exception:
            try:
                s = p.read_text(encoding='latin-1')
            except Exception:
                continue
        orig = s
        s = nav_link_re.sub('', s)
        s = css_block_re.sub('', s)
        s = html_cta_re.sub('', s)
        # also remove isolated links to /compass/ in text or buttons
        s = href_compass_re.sub('href="#"', s)
        if s != orig:
            p.write_text(s, encoding='utf-8')
            changed_files.append(str(p.relative_to(ROOT)))

print('Modified files:', len(changed_files))
for f in changed_files:
    print(f)

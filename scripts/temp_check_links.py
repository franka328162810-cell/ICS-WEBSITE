from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote

root = Path('public').resolve()
scan_roots = [root / 'en', root / 'zh', root / 'index.html', root / '404.html', root / 'admin']


class LinkParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.refs = []

    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if key in ('href', 'src') and value:
                self.refs.append((tag, key, value))


html_files = []
for item in scan_roots:
    if item.is_file():
        html_files.append(item)
    elif item.exists():
        html_files.extend(sorted(item.rglob('*.html')))

issues = []
for file in html_files:
    parser = LinkParser()
    parser.feed(file.read_text(encoding='utf-8', errors='ignore'))
    for tag, key, raw in parser.refs:
        if raw.startswith(('http://', 'https://', 'mailto:', 'tel:', 'data:', 'javascript:', '#')):
            continue
        clean = unquote(raw.split('?', 1)[0].split('#', 1)[0])
        if not clean:
            continue
        if clean.startswith('/'):
            target = root / clean.lstrip('/')
        else:
            target = (file.parent / clean).resolve()
        if not target.exists():
            try:
                resolved = str(target.relative_to(root)).replace('\\', '/')
            except ValueError:
                resolved = str(target)
            issues.append((str(file.relative_to(root)).replace('\\', '/'), raw, resolved))

for file_path, raw, resolved in issues[:250]:
    print(f'{file_path}\t{raw}\t{resolved}')
print(f'ISSUE_COUNT\t{len(issues)}')

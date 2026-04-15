from html.parser import HTMLParser
import pathlib
void_tags = {'area','base','br','col','embed','hr','img','input','link','meta','param','source','track','wbr'}
class TagChecker(HTMLParser):
    def __init__(self):
        super().__init__()
        self.stack=[]
        self.errors=[]
    def handle_starttag(self, tag, attrs):
        if tag not in void_tags:
            self.stack.append(tag)
    def handle_endtag(self, tag):
        if not self.stack:
            self.errors.append(f'unexpected </{tag}>')
            return
        expected = self.stack.pop()
        if expected != tag:
            self.errors.append(f'expected </{expected}>, got </{tag}>')
    def handle_startendtag(self, tag, attrs):
        pass
for path in ['public/en/daily-commentary.html', 'public/zh/每日热点评论.html']:
    text = pathlib.Path(path).read_text(encoding='utf-8')
    parser = TagChecker()
    parser.feed(text)
    print(path)
    print('errors:', parser.errors[:20])
    print('stack tail:', parser.stack[-20:])

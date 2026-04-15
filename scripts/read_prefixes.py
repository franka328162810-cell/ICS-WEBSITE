from pathlib import Path
for p in ['public/en/daily-commentary.html','public/zh/每日热点评论.html']:
    print('---', p)
    try:
        t = Path(p).read_text(encoding='utf-8')
        print(t[:400])
    except Exception as e:
        print('ERROR reading', p, e)

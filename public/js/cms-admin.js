(function () {
    const STORE_KEY = 'ics_cms_articles_v1';
    const form = () => document.getElementById('articleForm');
    const tableBody = () => document.getElementById('articleTableBody');

    const seed = [
        {
            id: crypto.randomUUID(),
            title: '深度研究：特朗普封杀Anthropic',
            slug: '深度研究',
            lang: 'zh',
            category: 'AI治理',
            tags: 'Anthropic,AI治理,伦理',
            summary: 'AI伦理红线与军事需求的文明级博弈。',
            status: 'published',
            updatedAt: new Date().toISOString()
        },
        {
            id: crypto.randomUUID(),
            title: "In-Depth Research: Trump's Ban on Anthropic",
            slug: 'in-depth-research',
            lang: 'en',
            category: 'AI Governance',
            tags: 'Anthropic,AI,ethics',
            summary: 'A civilization-level ethical dilemma between AI safety and military demands.',
            status: 'published',
            updatedAt: new Date().toISOString()
        }
    ];

    function getArticles() {
        try {
            const raw = localStorage.getItem(STORE_KEY);
            if (!raw) {
                localStorage.setItem(STORE_KEY, JSON.stringify(seed));
                return seed;
            }
            return JSON.parse(raw);
        } catch {
            return [];
        }
    }

    function setArticles(items) {
        localStorage.setItem(STORE_KEY, JSON.stringify(items));
    }

    function renderTable() {
        const items = getArticles().sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));
        tableBody().innerHTML = items.map(item => {
            const preview = item.lang === 'zh'
                ? `/zh/${item.slug}.html`
                : `/en/${item.slug}.html`;
            return `
            <tr>
                <td>${item.title}</td>
                <td>${item.lang}</td>
                <td>${item.category}</td>
                <td>${item.status}</td>
                <td>${new Date(item.updatedAt).toLocaleString()}</td>
                <td>
                    <button type="button" class="mini" onclick="ICSCMS.edit('${item.id}')">编辑</button>
                    <button type="button" class="mini danger" onclick="ICSCMS.remove('${item.id}')">删除</button>
                    <a class="mini" href="${preview}" target="_blank" rel="noopener">预览</a>
                </td>
            </tr>`;
        }).join('');
    }

    function resetForm() {
        form().reset();
        form().dataset.editId = '';
        document.getElementById('formTitle').textContent = '新建文章';
    }

    function collect() {
        const fd = new FormData(form());
        return {
            title: (fd.get('title') || '').toString().trim(),
            slug: (fd.get('slug') || '').toString().trim(),
            lang: (fd.get('lang') || 'zh').toString(),
            category: (fd.get('category') || '').toString().trim(),
            tags: (fd.get('tags') || '').toString().trim(),
            summary: (fd.get('summary') || '').toString().trim(),
            content: (fd.get('content') || '').toString().trim(),
            status: (fd.get('status') || 'draft').toString()
        };
    }

    function save(e) {
        e.preventDefault();
        const data = collect();
        if (!data.title || !data.slug || !data.category) {
            alert('请填写标题、slug、分类');
            return;
        }
        const items = getArticles();
        const id = form().dataset.editId;

        if (id) {
            const idx = items.findIndex(x => x.id === id);
            if (idx >= 0) {
                items[idx] = { ...items[idx], ...data, updatedAt: new Date().toISOString() };
            }
        } else {
            items.push({ id: crypto.randomUUID(), ...data, updatedAt: new Date().toISOString() });
        }

        setArticles(items);
        renderTable();
        resetForm();
        alert('已保存（MVP本地CMS）');
    }

    function edit(id) {
        const item = getArticles().find(x => x.id === id);
        if (!item) return;
        form().dataset.editId = id;
        document.getElementById('formTitle').textContent = '编辑文章';
        form().title.value = item.title || '';
        form().slug.value = item.slug || '';
        form().lang.value = item.lang || 'zh';
        form().category.value = item.category || '';
        form().tags.value = item.tags || '';
        form().summary.value = item.summary || '';
        form().content.value = item.content || '';
        form().status.value = item.status || 'draft';
    }

    function remove(id) {
        if (!confirm('确定删除这篇文章？')) return;
        const items = getArticles().filter(x => x.id !== id);
        setArticles(items);
        renderTable();
    }

    function exportJson() {
        const items = getArticles();
        const blob = new Blob([JSON.stringify(items, null, 2)], { type: 'application/json' });
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = `ics-cms-export-${new Date().toISOString().slice(0, 10)}.json`;
        a.click();
        URL.revokeObjectURL(a.href);
    }

    function buildContentIndex(items) {
        return items
            .filter(x => x.status === 'published')
            .map(x => ({
                id: x.id,
                lang: x.lang,
                title: x.title,
                category: x.category,
                date: (x.updatedAt || new Date().toISOString()).slice(0, 10),
                url: x.lang === 'zh' ? `/zh/${x.slug}.html` : `/en/${x.slug}.html`,
                keywords: (x.tags || '').split(',').map(s => s.trim()).filter(Boolean)
            }));
    }

    function exportContentIndex() {
        const items = getArticles();
        const index = buildContentIndex(items);
        const blob = new Blob([JSON.stringify(index, null, 2)], { type: 'application/json' });
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = 'content-index.json';
        a.click();
        URL.revokeObjectURL(a.href);
        alert('已导出 content-index.json。请将其覆盖到 public/data/content-index.json');
    }

    function bindImport() {
        const input = document.getElementById('importFile');
        if (!input) return;

        input.addEventListener('change', async (e) => {
            const file = e.target.files?.[0];
            if (!file) return;
            const text = await file.text();
            const parsed = JSON.parse(text);
            if (!Array.isArray(parsed)) {
                alert('导入失败：文件结构无效');
                return;
            }
            setArticles(parsed);
            renderTable();
            alert('导入成功');
        });
    }

    function init() {
        const session = window.ICSAuth?.requireAuth();
        if (!session) return;

        document.getElementById('adminUser').textContent = `${session.name} (${session.email})`;
        document.getElementById('articleForm').addEventListener('submit', save);
        document.getElementById('newBtn').addEventListener('click', resetForm);
        document.getElementById('exportBtn').addEventListener('click', exportJson);
        document.getElementById('exportIndexBtn').addEventListener('click', exportContentIndex);
        document.getElementById('logoutBtn').addEventListener('click', () => window.ICSAuth.logout());

        bindImport();
        renderTable();
        updateStats();
    }

    function updateStats() {
        // 文章统计
        const articles = getArticles();
        const published = articles.filter(a => a.status === 'published').length;
        document.getElementById('statTotalArticles').textContent = articles.length;
        document.getElementById('statPublished').textContent = published;

        // 订阅统计
        try {
            const subscribers = JSON.parse(localStorage.getItem('subscribers') || '[]');
            document.getElementById('statSubscribers').textContent = subscribers.length;
        } catch {
            document.getElementById('statSubscribers').textContent = '0';
        }

        // 反馈统计
        try {
            const feedback = JSON.parse(localStorage.getItem('articleFeedback') || '[]');
            const helpful = feedback.filter(f => f.helpful === true).length;
            document.getElementById('statHelpful').textContent = `${helpful}/${feedback.length}`;
        } catch {
            document.getElementById('statHelpful').textContent = '0/0';
        }
    }

    window.ICSCMS = { init, edit, remove };
})();
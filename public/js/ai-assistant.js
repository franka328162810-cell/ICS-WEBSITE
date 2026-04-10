/**
 * ICS 人工智能助手 (AI Assistant)
 * 星际文明学网站嵌入式智能问答组件
 * Version: 1.0.0
 * 
 * 功能：
 * - ICS 知识库 FAQ 智能匹配（中英双语）
 * - 可选连接 Cloudflare Workers AI 后端
 * - ICS 太空主题设计系统
 * - 移动端完美适配
 * 
 * 使用方式：
 *   <script src="/js/ai-assistant.js"></script>
 * 
 * 可选配置（在 script 标签前定义）：
 *   window.ICS_AI_CONFIG = {
 *     endpoint: 'https://your-worker.workers.dev/ai',  // Cloudflare Worker URL
 *     lang: 'auto'  // 'zh', 'en', or 'auto'
 *   };
 */
(function () {
  'use strict';

  /* ───────── Configuration ───────── */
  const CFG = Object.assign({
    endpoint: null,
    lang: 'auto',
    maxHistory: 20
  }, window.ICS_AI_CONFIG || {});

  /* ───────── Language Detection ───────── */
  function detectLang() {
    if (CFG.lang && CFG.lang !== 'auto') return CFG.lang;
    const html = document.documentElement.lang || '';
    if (/^zh/i.test(html)) return 'zh';
    if (/^en/i.test(html)) return 'en';
    if (location.pathname.includes('/zh/')) return 'zh';
    if (location.pathname.includes('/en/')) return 'en';
    return 'zh';
  }

  /* ───────── i18n Strings ───────── */
  const I18N = {
    zh: {
      title: 'ICS 人工智能助手',
      subtitle: '星际文明学 · 智能问答',
      placeholder: '输入您的问题…',
      send: '发送',
      welcome: '您好！我是 **ICS 人工智能助手**，很高兴为您服务。\n\n我可以回答关于星际文明学（ICS）的各种问题，包括核心理论、ICS 星际罗盘、最新研究等。\n\n请问有什么可以帮助您的？',
      quickReplies: [
        '什么是星际文明学？',
        '如何使用 ICS 星际罗盘？',
        '最新研究有哪些？',
        '什么是卡尔达肖夫指数？'
      ],
      typing: '正在思考',
      fallback: '感谢您的提问！这个问题超出了我目前的知识范围。\n\n您可以：\n- 浏览我们的 [深度研究](/zh/深度研究.html) 页面\n- 查看 [每日热点评论](/zh/每日热点评论.html)\n- 通过邮件联系我们：**ics@interstellar-civilization.org**\n\n或者尝试换个方式提问？',
      poweredBy: 'Powered by ICS AI'
    },
    en: {
      title: 'ICS AI Assistant',
      subtitle: 'Interstellar Civilization Studies · Smart Q&A',
      placeholder: 'Type your question…',
      send: 'Send',
      welcome: 'Hello! I\'m the **ICS AI Assistant**, happy to help you.\n\nI can answer questions about Interstellar Civilization Studies (ICS), including core theories, ICS Compass, latest research, and more.\n\nHow can I assist you today?',
      quickReplies: [
        'What is ICS?',
        'How to use ICS Compass?',
        'Latest research?',
        'What is the Kardashev Scale?'
      ],
      typing: 'Thinking',
      fallback: 'Thank you for your question! This is beyond my current knowledge base.\n\nYou can:\n- Browse our [In-Depth Research](/en/in-depth-research.html) page\n- Check the [Daily Commentary](/en/daily-commentary.html)\n- Contact us via email: **ics@interstellar-civilization.org**\n\nOr try rephrasing your question?',
      poweredBy: 'Powered by ICS AI'
    }
  };

  /* ───────── Knowledge Base ───────── */
  const KB = {
    zh: [
      {
        keywords: ['星际文明学', 'ICS', '什么是', '介绍', '简介'],
        patterns: [/什么是.*星际文明/, /ICS.*是什么/, /介绍.*ICS/, /星际文明学.*是/],
        answer: '**星际文明学 (Interstellar Civilization Studies, ICS)** 是一门跨学科研究领域，旨在从宇宙尺度审视人类文明的发展轨迹与未来可能性。\n\n🔬 **核心研究方向包括：**\n- 文明演化理论与卡尔达肖夫等级\n- 宇宙智能生命搜索 (SETI)\n- 星际治理框架与伦理\n- 技术奇点与文明跃迁\n- 行星际资源利用与可持续发展\n\nICS 致力于将天文学、社会学、政治学、技术哲学等多学科视角整合，为人类走向星际文明提供理论基础。\n\n📚 了解更多：访问我们的 [深度研究](/zh/深度研究.html) 页面。'
      },
      {
        keywords: ['星际罗盘', 'Compass', '罗盘', '评估工具', '使用'],
        patterns: [/星际罗盘/, /compass/i, /如何.*评估/, /怎么.*使用.*罗盘/],
        answer: '**ICS 星际罗盘 (ICS Compass)** 是我们开发的智能文明评估工具。\n\n🧭 **核心功能：**\n- 基于多维指标评估文明发展水平\n- 涵盖技术、治理、文化、可持续性等维度\n- 提供可视化评估报告\n- 支持中英双语\n\n📊 **四个版本：**\n- 🆓 **Free** — 基础评估体验\n- 💼 **Pro** — 完整评估 + 高级分析\n- 🎓 **Academic** — 学术研究版\n- 🏢 **Enterprise** — 机构定制版\n\n🔗 立即体验：[ICS 星际罗盘](/compass/)'
      },
      {
        keywords: ['卡尔达肖夫', 'Kardashev', '文明等级', '文明类型', 'I型', 'II型', 'III型', '能量'],
        patterns: [/卡尔达肖夫/, /Kardashev/i, /文明.*等级/, /文明.*类型/, /I{1,3}.*型.*文明/],
        answer: '**卡尔达肖夫指数 (Kardashev Scale)** 是由苏联天文学家尼古拉·卡尔达肖夫于 1964 年提出的文明等级分类方法。\n\n⭐ **三个基本等级：**\n\n**I 型文明（行星文明）**\n- 能够利用其所在行星的全部能量\n- 约 4×10¹⁶ W\n- 人类目前约在 0.73 级\n\n**II 型文明（恒星文明）**\n- 能够利用其恒星系统的全部能量\n- 约 4×10²⁶ W\n- 典型概念：戴森球\n\n**III 型文明（星系文明）**\n- 能够利用整个星系的能量\n- 约 4×10³⁷ W\n\n在 ICS 框架中，我们进一步将文明等级细分，并增加了治理、文化、伦理等非能量维度的评估指标。'
      },
      {
        keywords: ['费米悖论', 'Fermi', '外星人', '为什么没有', '大沉默', '在哪里'],
        patterns: [/费米.*悖论/, /Fermi/i, /外星人.*在哪/, /为什么.*没有.*外星/, /大沉默/],
        answer: '**费米悖论 (Fermi Paradox)** 是物理学家恩里科·费米提出的经典问题：如果宇宙中存在大量文明，为什么我们没有发现任何迹象？\n\n🤔 **主要假说：**\n\n1. **大过滤器假说** — 文明发展中存在极难跨越的障碍\n2. **动物园假说** — 高级文明故意不与我们接触\n3. **黑暗森林理论** — 文明为自保选择隐藏\n4. **距离假说** — 星际距离太大，信号尚未到达\n5. **独特地球假说** — 生命起源条件极其稀有\n\n在 ICS 视角下，费米悖论不仅是科学问题，更是关于文明选择和宇宙治理的哲学命题。这也是我们研究星际治理框架的核心动力之一。'
      },
      {
        keywords: ['德雷克', 'Drake', '方程', '公式', '外星文明数量'],
        patterns: [/德雷克.*方程/, /Drake/i, /外星.*数量/, /多少.*文明/],
        answer: '**德雷克方程 (Drake Equation)** 由天文学家弗兰克·德雷克于 1961 年提出，用于估算银河系中可通讯的外星文明数量。\n\n📐 **公式：**\n$N = R_* \\times f_p \\times n_e \\times f_l \\times f_i \\times f_c \\times L$\n\n| 参数 | 含义 |\n|------|------|\n| $R_*$ | 恒星形成速率 |\n| $f_p$ | 拥有行星的恒星比例 |\n| $n_e$ | 宜居行星数 |\n| $f_l$ | 产生生命的概率 |\n| $f_i$ | 演化出智慧的概率 |\n| $f_c$ | 发展通讯技术的概率 |\n| $L$ | 文明持续时间 |\n\n虽然参数存在巨大不确定性，但德雷克方程为思考宇宙中生命的存在提供了结构化框架。ICS 在此基础上扩展了文明可持续性和治理因素的分析。'
      },
      {
        keywords: ['每日', '评论', '热点', '最新', '文章', '内容', '新闻'],
        patterns: [/每日.*评论/, /最新.*文章/, /热点/, /有什么.*内容/, /最新.*研究/],
        answer: '**ICS 每日热点评论** 从星际文明学视角解读全球重大新闻和科技动态。\n\n📰 **我们的内容栏目：**\n\n1. **每日热点评论 (Daily Commentary)**\n   - 每日更新的新闻评论\n   - ICS 视角深度分析\n   - 中英双语版本\n   - 🔗 [中文版](/zh/每日热点评论.html) | [English](/en/daily-commentary.html)\n\n2. **深度研究 (In-Depth Research)**\n   - 长篇学术级分析报告\n   - 跨学科理论框架\n   - 🔗 [中文版](/zh/深度研究.html) | [English](/en/in-depth-research.html)\n\n3. **ICS 星际罗盘 (Compass)**\n   - 互动式文明评估工具\n   - 🔗 [立即体验](/compass/)'
      },
      {
        keywords: ['治理', '工具包', 'Governance', 'Toolkit', '框架'],
        patterns: [/治理.*工具/, /Governance/i, /Toolkit/i, /治理.*框架/],
        answer: '**ICS 治理工具包 (ICS Governance Toolkit)** 提供了一套星际文明治理框架。\n\n🛡️ **核心组件：**\n- 文明治理评估矩阵\n- 星际外交协议模板\n- 技术伦理审查标准\n- 跨文明沟通协议\n\n这套工具包旨在为人类从行星文明迈向星际文明的过程中，提供治理层面的理论支持和实践工具。'
      },
      {
        keywords: ['SETI', '搜索', '信号', '外星信号', '探测', '通信'],
        patterns: [/SETI/i, /搜索.*智慧/, /外星.*信号/, /探测.*协议/],
        answer: '**SETI (搜索地外智慧生命)** 是星际文明学的重要研究方向之一。\n\n📡 **ICS 关注的 SETI 议题：**\n- 探测后协议：发现外星信号后的应对方案\n- 主动 SETI vs 被动 SETI 的伦理争议\n- 信号解析与跨文明语言学\n- 宇宙安全与信息披露策略\n\n我们最新的文章讨论了 SETI 探测后协议的制度框架，欢迎查看 [每日热点评论](/zh/每日热点评论.html) 了解详情。'
      },
      {
        keywords: ['订阅', '关注', '联系', '邮箱', '邮件', '社交'],
        patterns: [/如何.*订阅/, /怎么.*关注/, /联系.*方式/, /邮箱/],
        answer: '📬 **关注 ICS 的方式：**\n\n- 🌐 **网站**: [interstellar-civilization-studies.pages.dev](https://interstellar-civilization-studies.pages.dev)\n- 📧 **邮件**: ics@interstellar-civilization.org\n- 📰 定期访问我们的每日热点评论和深度研究栏目\n\n我们会持续更新星际文明学领域的最新研究和评论，欢迎经常来访！'
      },
      {
        keywords: ['你好', '您好', 'hi', 'hello', '嗨', '在吗'],
        patterns: [/^你好/, /^您好/, /^hi/i, /^hello/i, /^嗨/, /^在吗/],
        answer: '您好！👋 很高兴为您服务！\n\n我是 ICS 人工智能助手，可以回答关于星际文明学的各种问题。请随时提问！'
      },
      {
        keywords: ['谢谢', '感谢', '多谢', 'thanks', 'thank'],
        patterns: [/谢谢/, /感谢/, /^thanks/i, /^thank/i],
        answer: '不客气！很高兴能帮到您 😊\n\n如果还有其他问题，随时提问！'
      },
      {
        keywords: ['你是谁', '你是什么', '自我介绍', '关于你'],
        patterns: [/你是谁/, /你是什么/, /自我介绍/, /关于你/],
        answer: '我是 **ICS 人工智能助手**，是星际文明学 (Interstellar Civilization Studies) 网站的智能问答系统。\n\n🤖 **我的能力：**\n- 回答关于星际文明学的知识性问题\n- 介绍 ICS 网站的内容和功能\n- 解释文明等级、费米悖论等核心概念\n- 引导您找到需要的资源\n\n有什么可以帮您的？'
      },
      {
        keywords: ['戴森球', 'Dyson', '巨型结构', '恒星工程'],
        patterns: [/戴森球/, /Dyson/i, /巨型结构/, /恒星.*工程/],
        answer: '**戴森球 (Dyson Sphere)** 是物理学家弗里曼·戴森于 1960 年提出的假想巨型结构。\n\n🔵 **核心概念：**\n- 一种环绕恒星的巨型结构，用于捕获恒星辐射能量\n- 是 II 型文明（卡尔达肖夫指数）的标志性技术\n- 变体包括：戴森环、戴森壳、戴森群\n\n在 ICS 框架中，戴森球不仅是能源技术的里程碑，更代表了文明从行星尺度向恒星尺度治理的根本性转变。'
      }
    ],
    en: [
      {
        keywords: ['ICS', 'interstellar', 'civilization', 'studies', 'what is'],
        patterns: [/what is.*ICS/i, /ICS.*about/i, /interstellar.*civilization/i],
        answer: '**Interstellar Civilization Studies (ICS)** is an interdisciplinary research field examining human civilization\'s trajectory and future possibilities from a cosmic scale.\n\n🔬 **Core Research Areas:**\n- Civilization evolution theory & Kardashev Scale\n- Search for Extraterrestrial Intelligence (SETI)\n- Interstellar governance frameworks & ethics\n- Technological singularity & civilization transitions\n- Interplanetary resource utilization\n\nICS integrates perspectives from astronomy, sociology, political science, and philosophy of technology.\n\n📚 Learn more: Visit our [In-Depth Research](/en/in-depth-research.html) page.'
      },
      {
        keywords: ['compass', 'evaluate', 'assessment', 'tool'],
        patterns: [/compass/i, /how.*evaluate/i, /assessment.*tool/i],
        answer: '**ICS Compass** is our intelligent civilization assessment tool.\n\n🧭 **Key Features:**\n- Multi-dimensional civilization assessment\n- Covers technology, governance, culture, sustainability\n- Visual assessment reports\n- Bilingual (Chinese/English)\n\n📊 **Four Tiers:**\n- 🆓 **Free** — Basic assessment\n- 💼 **Pro** — Full assessment + advanced analytics\n- 🎓 **Academic** — Research edition\n- 🏢 **Enterprise** — Custom institutional version\n\n🔗 Try it now: [ICS Compass](/compass/)'
      },
      {
        keywords: ['Kardashev', 'scale', 'civilization', 'type', 'level', 'energy'],
        patterns: [/Kardashev/i, /civilization.*type/i, /civilization.*level/i, /Type.*I{1,3}/i],
        answer: '**The Kardashev Scale** was proposed by Soviet astronomer Nikolai Kardashev in 1964 to classify civilizations by energy consumption.\n\n⭐ **Three Basic Types:**\n\n**Type I (Planetary)**\n- Harnesses all energy of its home planet\n- ~4×10¹⁶ W\n- Humanity is currently at ~0.73\n\n**Type II (Stellar)**\n- Harnesses all energy of its star system\n- ~4×10²⁶ W\n- Example: Dyson Sphere\n\n**Type III (Galactic)**\n- Harnesses energy of entire galaxy\n- ~4×10³⁷ W\n\nICS extends this framework with governance, cultural, and ethical dimensions beyond pure energy metrics.'
      },
      {
        keywords: ['Fermi', 'paradox', 'alien', 'why', 'silence', 'where'],
        patterns: [/Fermi.*paradox/i, /where.*alien/i, /great.*silence/i, /why.*no.*alien/i],
        answer: '**The Fermi Paradox** asks: if the universe likely hosts many civilizations, why haven\'t we found evidence of any?\n\n🤔 **Major Hypotheses:**\n\n1. **Great Filter** — Insurmountable barriers in civilization development\n2. **Zoo Hypothesis** — Advanced civilizations deliberately avoid contact\n3. **Dark Forest Theory** — Civilizations hide for self-preservation\n4. **Distance Hypothesis** — Interstellar distances are too vast\n5. **Rare Earth** — Conditions for life are exceptionally rare\n\nFrom an ICS perspective, the Fermi Paradox is not just a scientific question but a philosophical one about civilization choices and cosmic governance.'
      },
      {
        keywords: ['Drake', 'equation', 'number', 'civilizations', 'formula'],
        patterns: [/Drake.*equation/i, /how many.*civilization/i],
        answer: '**The Drake Equation**, proposed by Frank Drake in 1961, estimates the number of communicative civilizations in our galaxy.\n\n📐 **Formula:**\n$N = R_* \\times f_p \\times n_e \\times f_l \\times f_i \\times f_c \\times L$\n\nEach parameter represents a factor from star formation rate to civilization longevity. While individual values are uncertain, the equation provides a structured framework for thinking about extraterrestrial life.\n\nICS extends this by incorporating civilization sustainability and governance factors.'
      },
      {
        keywords: ['daily', 'commentary', 'article', 'latest', 'content', 'news', 'research'],
        patterns: [/daily.*commentary/i, /latest.*article/i, /latest.*research/i, /what.*content/i],
        answer: '**ICS Content Sections:**\n\n1. **Daily Commentary**\n   - Daily news analysis from ICS perspective\n   - Bilingual (CN/EN)\n   - 🔗 [English](/en/daily-commentary.html) | [中文](/zh/每日热点评论.html)\n\n2. **In-Depth Research**\n   - Academic-level analysis reports\n   - 🔗 [English](/en/in-depth-research.html) | [中文](/zh/深度研究.html)\n\n3. **ICS Compass**\n   - Interactive assessment tool\n   - 🔗 [Try it](/compass/)'
      },
      {
        keywords: ['hello', 'hi', 'hey', 'greetings'],
        patterns: [/^hello/i, /^hi\b/i, /^hey/i],
        answer: 'Hello! 👋 Welcome to ICS!\n\nI\'m the ICS AI Assistant. I can help you with questions about Interstellar Civilization Studies. Feel free to ask anything!'
      },
      {
        keywords: ['thank', 'thanks', 'appreciate'],
        patterns: [/thank/i, /appreciate/i],
        answer: 'You\'re welcome! 😊 Feel free to ask if you have more questions!'
      },
      {
        keywords: ['who', 'what are you', 'about you', 'introduce'],
        patterns: [/who are you/i, /what are you/i, /about you/i],
        answer: 'I\'m the **ICS AI Assistant**, the intelligent Q&A system for the Interstellar Civilization Studies website.\n\n🤖 **I can help with:**\n- ICS knowledge and concepts\n- Website navigation\n- Core theories (Kardashev, Fermi, Drake)\n- Finding the right resources\n\nHow can I help you?'
      },
      {
        keywords: ['SETI', 'search', 'signal', 'detection', 'protocol'],
        patterns: [/SETI/i, /search.*intelligence/i, /alien.*signal/i],
        answer: '**SETI (Search for Extraterrestrial Intelligence)** is a key research area in ICS.\n\n📡 **ICS SETI Topics:**\n- Post-detection protocols and response frameworks\n- Active vs. passive SETI ethics\n- Signal analysis and cross-civilization linguistics\n- Cosmic security and information disclosure\n\nCheck our [Daily Commentary](/en/daily-commentary.html) for the latest SETI analysis.'
      },
      {
        keywords: ['Dyson', 'sphere', 'megastructure'],
        patterns: [/Dyson/i, /megastructure/i],
        answer: '**Dyson Sphere** is a hypothetical megastructure proposed by Freeman Dyson in 1960.\n\n🔵 **Key Concept:**\n- A structure surrounding a star to capture its energy output\n- Hallmark technology of a Type II civilization\n- Variants: Dyson Ring, Dyson Shell, Dyson Swarm\n\nIn the ICS framework, a Dyson Sphere represents the fundamental shift from planetary to stellar-scale governance.'
      },
      {
        keywords: ['subscribe', 'follow', 'contact', 'email'],
        patterns: [/subscribe/i, /follow/i, /contact/i, /email/i],
        answer: '📬 **Stay Connected with ICS:**\n\n- 🌐 **Website**: [interstellar-civilization-studies.pages.dev](https://interstellar-civilization-studies.pages.dev)\n- 📧 **Email**: ics@interstellar-civilization.org\n- 📰 Visit our Daily Commentary and In-Depth Research regularly\n\nWe continuously update our analysis of the latest developments in interstellar civilization studies!'
      }
    ]
  };

  /* ───────── FAQ Matching Engine ───────── */
  function findAnswer(text, lang) {
    const input = text.toLowerCase().trim();
    if (!input) return null;

    const entries = KB[lang] || KB.zh;
    let bestScore = 0;
    let bestAnswer = null;

    for (const entry of entries) {
      let score = 0;

      // Pattern matching (highest priority)
      for (const pat of entry.patterns) {
        if (pat.test(input) || pat.test(text)) {
          score += 10;
          break;
        }
      }

      // Keyword matching
      for (const kw of entry.keywords) {
        const kwLower = kw.toLowerCase();
        if (input.includes(kwLower) || input.includes(kw)) {
          score += 3;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestAnswer = entry.answer;
      }
    }

    return bestScore >= 3 ? bestAnswer : null;
  }

  /* ───────── Markdown-lite renderer ───────── */
  function renderMd(text) {
    return text
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      .replace(/\*(.*?)\*/g, '<em>$1</em>')
      .replace(/\$(.*?)\$/g, '<code class="ics-ai-math">$1</code>')
      .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>')
      .replace(/\n/g, '<br>');
  }

  /* ───────── Call AI Endpoint (optional) ───────── */
  async function callAI(messages, lang) {
    if (!CFG.endpoint) return null;
    try {
      const systemPrompt = lang === 'zh'
        ? '你是 ICS 人工智能助手，星际文明学 (Interstellar Civilization Studies) 网站的智能问答系统。用中文回答，风格学术但通俗易懂。简洁回答，300字以内。'
        : 'You are the ICS AI Assistant for the Interstellar Civilization Studies website. Answer in English, academic but accessible. Keep answers concise, under 200 words.';

      const res = await fetch(CFG.endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messages: [
            { role: 'system', content: systemPrompt },
            ...messages.slice(-6)
          ]
        })
      });

      if (!res.ok) return null;
      const data = await res.json();
      return data.response || data.result?.response || data.choices?.[0]?.message?.content || null;
    } catch {
      return null;
    }
  }

  /* ───────── Inject Styles ───────── */
  function injectStyles() {
    if (document.getElementById('ics-ai-styles')) return;
    const style = document.createElement('style');
    style.id = 'ics-ai-styles';
    style.textContent = `
/* ICS AI Assistant Styles */
#ics-ai-assistant * { box-sizing: border-box; margin: 0; padding: 0; }
#ics-ai-assistant { font-family: 'Inter', 'Noto Sans SC', system-ui, -apple-system, sans-serif; font-size: 14px; line-height: 1.6; position: fixed; bottom: 24px; right: 24px; z-index: 99999; }

/* Toggle Button */
.ics-ai-toggle {
  width: 60px; height: 60px; border-radius: 50%; border: none; cursor: pointer;
  background: linear-gradient(135deg, #7c3aed 0%, #06b6d4 100%);
  box-shadow: 0 4px 20px rgba(124,58,237,0.4), 0 0 40px rgba(6,182,212,0.15);
  display: flex; align-items: center; justify-content: center;
  transition: all 0.3s cubic-bezier(0.4,0,0.2,1);
  position: relative; overflow: hidden;
}
.ics-ai-toggle:hover { transform: scale(1.08); box-shadow: 0 6px 28px rgba(124,58,237,0.5), 0 0 60px rgba(6,182,212,0.25); }
.ics-ai-toggle::after {
  content: ''; position: absolute; inset: -2px; border-radius: 50%;
  background: linear-gradient(135deg, rgba(124,58,237,0.6), rgba(6,182,212,0.6));
  animation: ics-ai-pulse 2s ease-in-out infinite; z-index: -1;
}
.ics-ai-toggle svg { width: 28px; height: 28px; fill: #fff; transition: transform 0.3s; }
.ics-ai-toggle.active svg { transform: rotate(90deg); }
@keyframes ics-ai-pulse { 0%,100% { opacity: 0; transform: scale(1); } 50% { opacity: 1; transform: scale(1.3); } }

/* Chat Window */
.ics-ai-window {
  position: absolute; bottom: 72px; right: 0;
  width: 400px; height: 560px;
  background: rgba(10,22,40,0.96);
  backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(124,58,237,0.3);
  border-radius: 16px; overflow: hidden;
  display: flex; flex-direction: column;
  box-shadow: 0 8px 40px rgba(0,0,0,0.5), 0 0 80px rgba(124,58,237,0.1);
  opacity: 0; transform: translateY(20px) scale(0.95);
  pointer-events: none;
  transition: all 0.35s cubic-bezier(0.4,0,0.2,1);
}
.ics-ai-window.open {
  opacity: 1; transform: translateY(0) scale(1); pointer-events: auto;
}

/* Header */
.ics-ai-header {
  padding: 16px 18px; display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(124,58,237,0.25) 0%, rgba(6,182,212,0.15) 100%);
  border-bottom: 1px solid rgba(124,58,237,0.2);
}
.ics-ai-header-info h3 { font-size: 15px; font-weight: 600; color: #fff; font-family: 'Orbitron','Inter',sans-serif; letter-spacing: 0.5px; }
.ics-ai-header-info p { font-size: 11px; color: rgba(255,255,255,0.55); margin-top: 2px; }
.ics-ai-close { width: 32px; height: 32px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.15); background: rgba(255,255,255,0.05); color: #fff; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 18px; transition: background 0.2s; }
.ics-ai-close:hover { background: rgba(255,255,255,0.12); }

/* Messages */
.ics-ai-messages { flex: 1; overflow-y: auto; padding: 16px; display: flex; flex-direction: column; gap: 12px; }
.ics-ai-messages::-webkit-scrollbar { width: 4px; }
.ics-ai-messages::-webkit-scrollbar-track { background: transparent; }
.ics-ai-messages::-webkit-scrollbar-thumb { background: rgba(124,58,237,0.3); border-radius: 2px; }

.ics-ai-msg { max-width: 85%; animation: ics-ai-fadeIn 0.3s ease-out; }
.ics-ai-msg.bot { align-self: flex-start; }
.ics-ai-msg.user { align-self: flex-end; }

.ics-ai-msg-bubble {
  padding: 10px 14px; border-radius: 12px; font-size: 13.5px; line-height: 1.65; color: #e0e0e0; word-break: break-word;
}
.ics-ai-msg.bot .ics-ai-msg-bubble {
  background: rgba(124,58,237,0.12); border: 1px solid rgba(124,58,237,0.2); border-bottom-left-radius: 4px;
}
.ics-ai-msg.user .ics-ai-msg-bubble {
  background: rgba(6,182,212,0.18); border: 1px solid rgba(6,182,212,0.25); border-bottom-right-radius: 4px; color: #fff;
}
.ics-ai-msg-bubble a { color: #06b6d4; text-decoration: underline; text-underline-offset: 2px; }
.ics-ai-msg-bubble a:hover { color: #22d3ee; }
.ics-ai-msg-bubble strong { color: #fff; }
.ics-ai-msg-bubble code.ics-ai-math { background: rgba(245,158,11,0.15); padding: 1px 4px; border-radius: 3px; font-size: 12px; color: #f59e0b; }
.ics-ai-msg-time { font-size: 10px; color: rgba(255,255,255,0.3); margin-top: 4px; padding: 0 4px; }
.ics-ai-msg.user .ics-ai-msg-time { text-align: right; }

/* Quick Replies */
.ics-ai-quick { display: flex; flex-wrap: wrap; gap: 6px; padding: 0 16px 12px; }
.ics-ai-quick button {
  padding: 6px 12px; border-radius: 16px; font-size: 12px; cursor: pointer;
  background: rgba(124,58,237,0.1); border: 1px solid rgba(124,58,237,0.3); color: #a78bfa;
  transition: all 0.2s; white-space: nowrap;
}
.ics-ai-quick button:hover { background: rgba(124,58,237,0.2); color: #c4b5fd; border-color: rgba(124,58,237,0.5); }

/* Typing Indicator */
.ics-ai-typing { display: flex; align-items: center; gap: 6px; padding: 10px 14px; }
.ics-ai-typing-text { font-size: 12px; color: rgba(255,255,255,0.4); }
.ics-ai-typing-dots { display: flex; gap: 4px; }
.ics-ai-typing-dots span { width: 6px; height: 6px; border-radius: 50%; background: #7c3aed; animation: ics-ai-bounce 1.4s ease-in-out infinite; }
.ics-ai-typing-dots span:nth-child(2) { animation-delay: 0.2s; }
.ics-ai-typing-dots span:nth-child(3) { animation-delay: 0.4s; }
@keyframes ics-ai-bounce { 0%,60%,100% { transform: translateY(0); opacity: 0.4; } 30% { transform: translateY(-6px); opacity: 1; } }
@keyframes ics-ai-fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

/* Input Area */
.ics-ai-input-area {
  padding: 12px 16px; display: flex; gap: 8px; align-items: center;
  border-top: 1px solid rgba(124,58,237,0.15); background: rgba(255,255,255,0.02);
}
.ics-ai-input {
  flex: 1; padding: 10px 14px; border-radius: 10px; font-size: 13.5px;
  background: rgba(255,255,255,0.06); border: 1px solid rgba(124,58,237,0.2);
  color: #fff; outline: none; font-family: inherit; resize: none;
  transition: border-color 0.2s;
}
.ics-ai-input::placeholder { color: rgba(255,255,255,0.3); }
.ics-ai-input:focus { border-color: rgba(124,58,237,0.5); }
.ics-ai-send {
  width: 40px; height: 40px; border-radius: 10px; border: none; cursor: pointer;
  background: linear-gradient(135deg, #7c3aed, #06b6d4);
  display: flex; align-items: center; justify-content: center;
  transition: opacity 0.2s, transform 0.2s; flex-shrink: 0;
}
.ics-ai-send:hover { opacity: 0.9; transform: scale(1.05); }
.ics-ai-send:disabled { opacity: 0.4; cursor: not-allowed; transform: none; }
.ics-ai-send svg { width: 18px; height: 18px; fill: #fff; }

/* Footer */
.ics-ai-footer { text-align: center; padding: 6px; font-size: 10px; color: rgba(255,255,255,0.2); }

/* Mobile */
@media (max-width: 480px) {
  #ics-ai-assistant { bottom: 16px; right: 16px; }
  .ics-ai-toggle { width: 52px; height: 52px; }
  .ics-ai-toggle svg { width: 24px; height: 24px; }
  .ics-ai-window {
    position: fixed; bottom: 0; right: 0; left: 0; top: 0;
    width: 100%; height: 100%; border-radius: 0;
  }
}
`;
    document.head.appendChild(style);
  }

  /* ───────── Create Widget DOM ───────── */
  function createWidget() {
    const lang = detectLang();
    const t = I18N[lang] || I18N.zh;

    const container = document.createElement('div');
    container.id = 'ics-ai-assistant';

    container.innerHTML = `
      <button class="ics-ai-toggle" aria-label="${t.title}" title="${t.title}">
        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 2C6.48 2 2 6.04 2 11c0 2.76 1.36 5.22 3.5 6.84V22l3.73-2.05c.87.24 1.8.37 2.77.37 5.52 0 10-4.04 10-9S17.52 2 12 2zm1.07 12.14l-2.54-2.72L5.8 14.14l4.94-5.24 2.54 2.72 4.73-2.72-4.94 5.24z"/>
        </svg>
      </button>
      <div class="ics-ai-window">
        <div class="ics-ai-header">
          <div class="ics-ai-header-info">
            <h3>${t.title}</h3>
            <p>${t.subtitle}</p>
          </div>
          <button class="ics-ai-close" aria-label="Close">✕</button>
        </div>
        <div class="ics-ai-messages"></div>
        <div class="ics-ai-quick"></div>
        <div class="ics-ai-input-area">
          <input type="text" class="ics-ai-input" placeholder="${t.placeholder}" autocomplete="off" />
          <button class="ics-ai-send" aria-label="${t.send}">
            <svg viewBox="0 0 24 24"><path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/></svg>
          </button>
        </div>
        <div class="ics-ai-footer">${t.poweredBy}</div>
      </div>
    `;

    document.body.appendChild(container);
    return container;
  }

  /* ───────── Widget Controller ───────── */
  function initWidget() {
    injectStyles();
    const el = createWidget();
    const lang = detectLang();
    const t = I18N[lang] || I18N.zh;

    const toggle = el.querySelector('.ics-ai-toggle');
    const win = el.querySelector('.ics-ai-window');
    const closeBtn = el.querySelector('.ics-ai-close');
    const messagesEl = el.querySelector('.ics-ai-messages');
    const quickEl = el.querySelector('.ics-ai-quick');
    const input = el.querySelector('.ics-ai-input');
    const sendBtn = el.querySelector('.ics-ai-send');

    let isOpen = false;
    let history = [];
    let isProcessing = false;

    function toggleOpen() {
      isOpen = !isOpen;
      win.classList.toggle('open', isOpen);
      toggle.classList.toggle('active', isOpen);
      if (isOpen) {
        input.focus();
        if (messagesEl.children.length === 0) showWelcome();
      }
    }

    function showWelcome() {
      addMessage('bot', t.welcome);
      showQuickReplies(t.quickReplies);
    }

    function showQuickReplies(items) {
      quickEl.innerHTML = '';
      items.forEach(text => {
        const btn = document.createElement('button');
        btn.textContent = text;
        btn.addEventListener('click', () => {
          quickEl.innerHTML = '';
          handleSend(text);
        });
        quickEl.appendChild(btn);
      });
    }

    function addMessage(role, text) {
      const now = new Date();
      const timeStr = now.getHours().toString().padStart(2, '0') + ':' + now.getMinutes().toString().padStart(2, '0');

      const msgEl = document.createElement('div');
      msgEl.className = 'ics-ai-msg ' + role;
      msgEl.innerHTML = `
        <div class="ics-ai-msg-bubble">${renderMd(text)}</div>
        <div class="ics-ai-msg-time">${timeStr}</div>
      `;
      messagesEl.appendChild(msgEl);
      messagesEl.scrollTop = messagesEl.scrollHeight;

      history.push({ role: role === 'bot' ? 'assistant' : 'user', content: text });
      if (history.length > CFG.maxHistory) history = history.slice(-CFG.maxHistory);
    }

    function showTyping() {
      const el = document.createElement('div');
      el.className = 'ics-ai-msg bot';
      el.id = 'ics-ai-typing-msg';
      el.innerHTML = `
        <div class="ics-ai-typing">
          <div class="ics-ai-typing-dots"><span></span><span></span><span></span></div>
          <span class="ics-ai-typing-text">${t.typing}…</span>
        </div>
      `;
      messagesEl.appendChild(el);
      messagesEl.scrollTop = messagesEl.scrollHeight;
    }

    function removeTyping() {
      const el = document.getElementById('ics-ai-typing-msg');
      if (el) el.remove();
    }

    async function handleSend(text) {
      if (!text || !text.trim() || isProcessing) return;
      text = text.trim();
      isProcessing = true;
      sendBtn.disabled = true;
      input.value = '';
      quickEl.innerHTML = '';

      addMessage('user', text);
      showTyping();

      // Simulate thinking delay
      const delay = 600 + Math.random() * 800;

      // Try FAQ first
      const faqAnswer = findAnswer(text, lang);

      if (faqAnswer) {
        await new Promise(r => setTimeout(r, delay));
        removeTyping();
        addMessage('bot', faqAnswer);
      } else if (CFG.endpoint) {
        // Try AI backend
        const aiMessages = history
          .filter(m => m.role === 'user' || m.role === 'assistant')
          .map(m => ({ role: m.role, content: m.content }));
        const aiAnswer = await callAI(aiMessages, lang);
        removeTyping();
        if (aiAnswer) {
          addMessage('bot', aiAnswer);
        } else {
          addMessage('bot', t.fallback);
        }
      } else {
        await new Promise(r => setTimeout(r, delay));
        removeTyping();
        addMessage('bot', t.fallback);
      }

      // Suggest follow-up after fallback
      isProcessing = false;
      sendBtn.disabled = false;
      input.focus();
    }

    // Event listeners
    toggle.addEventListener('click', toggleOpen);
    closeBtn.addEventListener('click', toggleOpen);

    sendBtn.addEventListener('click', () => handleSend(input.value));
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        handleSend(input.value);
      }
    });

    // Close on Escape
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && isOpen) toggleOpen();
    });
  }

  /* ───────── Auto-Initialize ───────── */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initWidget);
  } else {
    initWidget();
  }

})();

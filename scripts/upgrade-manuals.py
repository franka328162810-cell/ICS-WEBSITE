#!/usr/bin/env python3
"""
Upgrade all 4 manual.html files to ICS design system:
- Inject ICS navbar
- Replace inline fonts with ICS Google Fonts + shared CSS
- Override key styles with ICS design tokens
- Add ICS footer
"""
import os
import re

BASE = r"C:\Users\Administrator\Documents\ics-website\public\compass"

# ICS Navbar HTML (shared across all compass pages)
NAVBAR_HTML = '''
    <!-- ══════════ Navbar ══════════ -->
    <nav class="navbar" id="navbar">
        <div class="nav-container">
            <a href="/en/index.html" class="nav-brand">
                <svg class="nav-logo" viewBox="0 0 44 44" fill="none">
                    <circle cx="22" cy="22" r="20" stroke="rgba(167,139,250,0.25)" stroke-width="1" fill="none"/>
                    <circle cx="22" cy="22" r="13" stroke="rgba(6,182,212,0.2)" stroke-width="1" fill="none"/>
                    <circle cx="22" cy="22" r="5" fill="rgba(167,139,250,0.9)"/>
                    <circle cx="22" cy="4" r="2.5" fill="rgba(6,182,212,1)">
                        <animateTransform attributeName="transform" type="rotate" from="0 22 22" to="360 22 22" dur="8s" repeatCount="indefinite"/>
                    </circle>
                </svg>
                <div class="nav-brand-text">
                    <span class="nav-title">ICS</span>
                    <span class="nav-subtitle">Interstellar Civilization Studies</span>
                </div>
            </a>
            <ul class="nav-links" id="nav-links">
                <li><a href="/en/index.html" class="nav-link">Home</a></li>
                <li><a href="/en/about.html" class="nav-link">About</a></li>
                <li><a href="/en/book-overview.html" class="nav-link">Publications</a></li>
                <li><a href="/en/resources.html" class="nav-link">Resources</a></li>
                <li><a href="/en/daily-commentary.html" class="nav-link">News</a></li>
                <li><a href="/en/ai-assistant.html" class="nav-link">AI Assistant</a></li>
                <li><a href="/compass/" class="nav-link active">Compass</a></li>
            </ul>
            <div class="nav-actions">
                <div class="lang-switch">
                    <a href="/en/index.html" class="lang-btn active">EN</a>
                    <a href="/zh/首页.html" class="lang-btn">中文</a>
                </div>
                <button class="nav-hamburger" id="nav-hamburger" aria-label="Menu">
                    <span></span><span></span><span></span>
                </button>
            </div>
        </div>
    </nav>
'''

# ICS style overrides to inject in <head> (after existing <style>)
ICS_STYLE_OVERRIDE = '''
    <!-- ICS Design System Override -->
    <link rel="stylesheet" href="/css/ics-sizefix.css">
    <style>
        /* ICS Design Tokens */
        :root {
            --color-deep-space: #0a1628;
            --color-quantum-purple: #7c3aed;
            --color-quantum-purple-light: #a78bfa;
            --color-nebula-cyan: #06b6d4;
            --color-nebula-cyan-light: #22d3ee;
            --color-energy-gold: #f59e0b;
            --glass-bg: rgba(255,255,255,0.02);
            --glass-border: rgba(255,255,255,0.06);
            --font-en-display: 'Orbitron', sans-serif;
            --font-en-title: 'Space Grotesk', sans-serif;
            --font-en-body: 'Inter', sans-serif;
            --font-zh-sans: 'Noto Sans SC', sans-serif;
            --radius-sm: 8px; --radius-md: 12px; --radius-lg: 16px; --radius-full: 9999px;
            --shadow-md: 0 8px 30px rgba(0,0,0,0.3);
            --shadow-glow: 0 4px 20px rgba(124,58,237,0.4);
            --transition-fast: 0.2s ease; --transition-normal: 0.3s ease; --transition-slow: 0.4s ease;
        }
        body {
            background: linear-gradient(to bottom, var(--color-deep-space), #050a14) !important;
            font-family: var(--font-en-body) !important;
        }
        /* Navbar */
        .navbar {
            position: fixed; top: 0; left: 0; right: 0; z-index: 1000;
            height: 80px; background: rgba(10,22,40,0.75);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(124,58,237,0.15);
            transition: all var(--transition-slow);
        }
        .navbar.scrolled { height: 64px; background: rgba(10,22,40,0.92); box-shadow: var(--shadow-md); }
        .nav-container {
            max-width: 1400px; height: 100%; margin: 0 auto; padding: 0 2rem;
            display: flex; justify-content: space-between; align-items: center;
        }
        .nav-brand { display: flex; align-items: center; gap: 12px; text-decoration: none !important; }
        .nav-logo { width: 44px; height: 44px; }
        .nav-brand-text { display: flex; flex-direction: column; }
        .nav-title { font-family: var(--font-en-display); font-size: 1.25rem; font-weight: 700; letter-spacing: 0.1em; color: #fff; }
        .nav-subtitle { font-family: var(--font-en-body); font-size: 0.625rem; color: rgba(255,255,255,0.4); }
        .nav-links { display: flex; gap: 2rem; align-items: center; list-style: none; margin: 0; padding: 0; }
        .nav-link {
            font-family: var(--font-en-display) !important; font-size: 0.8rem !important;
            font-weight: 500; letter-spacing: 0.05em; text-transform: uppercase;
            color: rgba(255,255,255,0.75) !important; padding: 8px 0; position: relative;
            transition: color var(--transition-normal); text-decoration: none !important;
        }
        .nav-link:hover, .nav-link.active { color: #fff !important; }
        .nav-link::after {
            content: ''; position: absolute; bottom: 0; left: 0;
            width: 0; height: 2px;
            background: linear-gradient(90deg, var(--color-quantum-purple), var(--color-nebula-cyan));
            transition: width var(--transition-normal);
        }
        .nav-link:hover::after, .nav-link.active::after { width: 100%; }
        .nav-actions { display: flex; align-items: center; gap: 12px; }
        .lang-switch {
            display: flex; height: 42px; background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.12); border-radius: var(--radius-md);
            padding: 4px; gap: 4px;
        }
        .lang-btn {
            font-family: var(--font-en-body); font-size: 0.8125rem; font-weight: 500;
            color: rgba(255,255,255,0.5); padding: 6px 14px; border-radius: 8px;
            text-decoration: none !important; transition: all var(--transition-normal);
        }
        .lang-btn:hover { color: rgba(255,255,255,0.9); background: rgba(255,255,255,0.08); }
        .lang-btn.active {
            background: linear-gradient(135deg, var(--color-quantum-purple), var(--color-nebula-cyan));
            color: #fff;
        }
        .nav-hamburger {
            display: none; flex-direction: column; gap: 5px; cursor: pointer;
            padding: 8px; background: none; border: none;
        }
        .nav-hamburger span { width: 24px; height: 2px; background: rgba(255,255,255,0.8); }

        /* Content area padding for fixed navbar */
        .container { padding-top: 6rem !important; }

        /* Glass card upgrade */
        .card {
            background: var(--glass-bg) !important;
            border: 1px solid var(--glass-border) !important;
            border-radius: var(--radius-lg) !important;
            backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px);
            transition: all var(--transition-normal);
        }
        .card:hover {
            border-color: rgba(167,139,250,0.2) !important;
        }

        /* Heading style overrides */
        h1 {
            font-family: var(--font-en-display) !important;
            background: linear-gradient(135deg, #ffffff 0%, var(--color-quantum-purple-light) 50%, var(--color-nebula-cyan) 100%) !important;
            -webkit-background-clip: text !important; -webkit-text-fill-color: transparent !important;
            background-clip: text !important;
        }
        h2 {
            font-family: var(--font-en-display) !important;
            color: var(--color-quantum-purple-light) !important;
            border-bottom-color: rgba(124,58,237,0.15) !important;
        }
        h3 { color: var(--color-nebula-cyan-light) !important; }

        /* Table glass effect */
        th {
            background: rgba(124,58,237,0.1) !important;
            color: var(--color-quantum-purple-light) !important;
            border-color: rgba(124,58,237,0.15) !important;
        }
        td { border-color: rgba(255,255,255,0.06) !important; }

        /* Highlight bar */
        .highlight { border-left-color: var(--color-nebula-cyan) !important; }

        /* Back link */
        .back {
            color: rgba(255,255,255,0.6) !important; text-decoration: none !important;
        }
        .back:hover { color: var(--color-quantum-purple-light) !important; text-decoration: none !important; }

        /* Footer */
        .ics-footer {
            border-top: 1px solid rgba(124,58,237,0.15);
            padding: 2rem; text-align: center;
            color: rgba(255,255,255,0.4); font-size: 0.85rem;
            margin-top: 3rem;
        }
        .ics-footer a { color: var(--color-quantum-purple-light); text-decoration: none; }
        .ics-footer a:hover { text-decoration: underline; }

        /* Responsive */
        @media (max-width: 1024px) {
            .nav-links { gap: 1.5rem; }
            .nav-link { font-size: 0.7rem !important; }
        }
        @media (max-width: 768px) {
            .navbar { height: 64px; }
            .nav-links {
                display: none; position: absolute; top: 64px; left: 0; right: 0;
                flex-direction: column; background: rgba(10,22,40,0.95);
                padding: 1rem 2rem; gap: 0; border-bottom: 1px solid rgba(124,58,237,0.15);
                backdrop-filter: blur(20px);
            }
            .nav-links.active { display: flex; }
            .nav-link { padding: 12px 0 !important; width: 100%; }
            .nav-hamburger { display: flex; }
            .nav-actions .lang-switch { display: none; }
            .container { padding-top: 5rem !important; }
        }
    </style>
'''

# ICS Footer HTML
ICS_FOOTER = '''
    <div class="ics-footer">
        <p>© 2026 <a href="https://ics-studies.org">Interstellar Civilization Studies</a>. All rights reserved.</p>
        <p style="margin-top:0.5rem"><a href="/compass/">← Back to Compass Editions</a> · <a href="mailto:franka328162810@gmail.com">Contact</a></p>
    </div>
'''

# Navbar JS
NAVBAR_JS = '''
    <script>
    (function() {
        'use strict';
        var navbar = document.getElementById('navbar');
        if (navbar) {
            window.addEventListener('scroll', function() {
                navbar.classList.toggle('scrolled', window.scrollY > 30);
            });
        }
        var hamburger = document.getElementById('nav-hamburger');
        var navLinks = document.getElementById('nav-links');
        if (hamburger) {
            hamburger.addEventListener('click', function() { navLinks.classList.toggle('active'); });
        }
    })();
    </script>
'''


def upgrade_manual(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Replace Google Fonts link with ICS version (including Space Grotesk)
    content = re.sub(
        r'<link\s+href="https://fonts\.googleapis\.com/css2\?[^"]*"\s+rel="stylesheet">',
        '<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700;800;900&family=Space+Grotesk:wght@300;400;500;600;700&family=Inter:wght@300;400;500;600&family=Noto+Sans+SC:wght@300;400;500;600;700&display=swap" rel="stylesheet">',
        content
    )

    # 2. Inject ICS style overrides after closing </style>
    content = content.replace('</style>\n</head>', '</style>\n' + ICS_STYLE_OVERRIDE + '\n</head>')
    # Fallback if no newline
    if ICS_STYLE_OVERRIDE not in content:
        content = content.replace('</style></head>', '</style>' + ICS_STYLE_OVERRIDE + '</head>')

    # 3. Inject navbar right after <body>
    content = content.replace('<body>\n', '<body>\n' + NAVBAR_HTML + '\n')
    if NAVBAR_HTML not in content:
        content = content.replace('<body>', '<body>\n' + NAVBAR_HTML)

    # 4. Replace the old footer with ICS footer
    # Original footer pattern: <div class="footer">...</div>
    content = re.sub(
        r'<div class="footer">.*?</div>',
        ICS_FOOTER,
        content,
        flags=re.DOTALL
    )

    # 5. Inject navbar JS before </body>
    if 'nav-hamburger' not in content.split('</body>')[0].split('<script')[-1] if '<script' in content else True:
        content = content.replace('</body>', NAVBAR_JS + '\n</body>')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

    return True


def main():
    tiers = ['free', 'pro', 'academic', 'enterprise']
    for tier in tiers:
        filepath = os.path.join(BASE, tier, 'manual.html')
        if os.path.exists(filepath):
            try:
                upgrade_manual(filepath)
                print(f"  ✓ {tier}/manual.html upgraded")
            except Exception as e:
                print(f"  ✗ {tier}/manual.html: {e}")
        else:
            print(f"  - {tier}/manual.html not found")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Fix navbar in all 4 manual.html files to match ICS website design."""
import re, os

TIERS = ['free', 'pro', 'academic', 'enterprise']
BASE = os.path.join(os.path.dirname(__file__), '..', 'public', '')

SEARCH_CONTACT_CSS = """
        .nav-search {
            background: none; border: none; color: rgba(255,255,255,0.6);
            width: 20px; height: 20px; cursor: pointer; padding: 0;
            transition: color var(--transition-fast);
        }
        .nav-search:hover { color: var(--color-quantum-purple-light); }
        .nav-search svg { width: 20px; height: 20px; }
        .nav-contact {
            font-family: var(--font-en-title); font-size: 0.8125rem;
            font-weight: 600; padding: 8px 20px; border-radius: var(--radius-sm);
            background: linear-gradient(135deg, var(--color-quantum-purple), var(--color-nebula-cyan));
            color: #fff; transition: all var(--transition-fast); text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .nav-contact:hover { transform: translateY(-1px); box-shadow: var(--shadow-glow); }"""

SEARCH_CONTACT_HTML = """                <button class="nav-search" aria-label="Search">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="11" cy="11" r="8"></circle>
                        <path d="m21 21-4.35-4.35"></path>
                    </svg>
                </button>"""

CONTACT_HTML = '                <a href="/en/contact-us.html" class="nav-contact">Contact</a>'

for tier in TIERS:
    path = os.path.join(BASE, tier, 'manual.html')
    with open(path, 'r', encoding='utf-8') as f:
        html = f.read()
    
    original = html
    
    # 1. Fix nav-links gap: 2rem → 2.5rem + add flex:1 justify-content:center
    html = html.replace(
        'gap: 2rem; align-items: center; list-style: none;',
        'gap: 2.5rem; align-items: center; flex: 1; justify-content: center; list-style: none;'
    )
    
    # 2. Fix nav-link font-size: 0.8rem → 0.875rem
    html = html.replace(
        'font-size: 0.8rem !important;',
        'font-size: 0.875rem !important;'
    )
    
    # 3. Add nav-search and nav-contact CSS after nav-actions line
    html = html.replace(
        '.nav-actions { display: flex; align-items: center; gap: 12px; }',
        '.nav-actions { display: flex; align-items: center; gap: 12px; }' + SEARCH_CONTACT_CSS
    )
    
    # 4. Fix responsive 0.7rem → 0.75rem and add hide rules
    html = html.replace(
        '.nav-link { font-size: 0.7rem !important; }',
        '.nav-link { font-size: 0.75rem !important; }\n            .nav-contact { display: none; }'
    )
    html = html.replace(
        '.nav-actions .lang-switch { display: none; }',
        '.nav-actions .lang-switch { display: none; }\n            .nav-actions .nav-search { display: none; }\n            .nav-actions .nav-contact { display: none; }'
    )
    
    # 5. Fix mobile nav-link font-size override
    # In 768px media query, add font-size
    html = html.replace(
        '.nav-link { padding: 12px 0 !important; width: 100%; }',
        '.nav-link { padding: 12px 0 !important; width: 100%; font-size: 0.875rem !important; }'
    )
    
    # 6. Add search button and contact to nav-actions HTML
    # Replace the nav-actions div content
    html = html.replace(
        '''            <div class="nav-actions">
                <div class="lang-switch">''',
        '''            <div class="nav-actions">
''' + SEARCH_CONTACT_HTML + '''
                <div class="lang-switch">'''
    )
    
    # Add contact link before hamburger
    html = html.replace(
        '''                <button class="nav-hamburger" id="nav-hamburger" aria-label="Menu">''',
        CONTACT_HTML + '''
                <button class="nav-hamburger" id="nav-hamburger" aria-label="Menu">'''
    )
    
    if html != original:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(html)
        print(f"✓ {tier}/manual.html updated")
    else:
        print(f"⚠ {tier}/manual.html no changes")

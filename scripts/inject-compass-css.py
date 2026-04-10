#!/usr/bin/env python3
"""
Inject CSS overrides into all 4 tier index.html files for the ICS Compass PWA.
Also updates service-worker.js revision hashes to force cache invalidation.

Fixes:
1. Nav link font → Orbitron (matching hero title)
2. Card hover 3D floating effect (translateY + box-shadow)
3. SW cache bust → forces re-fetch of new "治理" version
"""

import os
import hashlib
import re
import datetime

BASE = os.path.join('public', 'compass')
TIERS = ['free', 'pro', 'academic', 'enterprise']

# CSS overrides to inject
CSS_OVERRIDES = """
<style id="ics-compass-overrides">
  /* === ICS Compass CSS Overrides === */
  /* Generated: """ + datetime.datetime.now().strftime('%Y-%m-%d %H:%M') + """ */

  /* --- Nav Link Font: match hero title (Orbitron) --- */
  .compass-nav-link {
    font-family: var(--font-display) !important;
    font-weight: 600 !important;
    letter-spacing: 0.04em !important;
    font-size: 0.8125rem !important;
    text-transform: uppercase !important;
  }
  .compass-nav-link:hover {
    color: var(--color-text-primary) !important;
    background: rgba(167, 139, 250, 0.1) !important;
  }
  .compass-nav-link.active {
    color: var(--color-purple-light) !important;
    background: rgba(167, 139, 250, 0.15) !important;
    font-weight: 700 !important;
  }
  .compass-nav-links {
    gap: 0.375rem !important;
  }
  .compass-nav-lang {
    font-family: var(--font-display) !important;
    text-transform: uppercase !important;
    letter-spacing: 0.05em !important;
  }

  /* --- Card 3D Floating Hover Effect --- */
  .card,
  .feature-card {
    transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1) !important;
    position: relative;
  }
  .card:hover,
  .feature-card:hover {
    transform: translateY(-6px) !important;
    box-shadow:
      0 12px 40px rgba(167, 139, 250, 0.15),
      0 4px 12px rgba(0, 0, 0, 0.25),
      inset 0 1px 0 rgba(255, 255, 255, 0.05) !important;
    border-color: var(--color-border-hover) !important;
    background: var(--color-bg-card-hover) !important;
  }
  .feature-card::after {
    content: '';
    position: absolute;
    inset: 0;
    border-radius: 16px;
    opacity: 0;
    transition: opacity 0.35s;
    background: radial-gradient(
      600px circle at var(--mouse-x, 50%) var(--mouse-y, 50%),
      rgba(167, 139, 250, 0.06),
      transparent 40%
    );
    pointer-events: none;
  }
  .feature-card:hover::after {
    opacity: 1;
  }

  /* --- Feature title font alignment --- */
  .feature-title {
    font-family: var(--font-display) !important;
    letter-spacing: 0.03em !important;
  }

  /* --- Section title consistency --- */
  .section-title {
    font-family: var(--font-display) !important;
  }
</style>
"""

def inject_css(tier):
    """Inject CSS overrides into a tier's index.html and update SW revision."""
    idx_path = os.path.join(BASE, tier, 'index.html')
    sw_path = os.path.join(BASE, tier, 'service-worker.js')

    if not os.path.exists(idx_path):
        print(f"  [WARN] {idx_path} not found, skipping")
        return False

    # Read current index.html
    with open(idx_path, 'r', encoding='utf-8') as f:
        html = f.read()

    # Remove any existing overrides (idempotent)
    html = re.sub(r'<style id="ics-compass-overrides">.*?</style>\s*', '', html, flags=re.DOTALL)

    # Inject CSS before </head>
    if '</head>' in html:
        html = html.replace('</head>', CSS_OVERRIDES.strip() + '\n</head>')
    else:
        print(f"  [WARN] No </head> found in {idx_path}")
        return False

    # Write updated index.html
    with open(idx_path, 'w', encoding='utf-8', newline='') as f:
        f.write(html)

    # Calculate new MD5 for SW revision
    new_md5 = hashlib.md5(html.encode('utf-8')).hexdigest()
    print(f"  [OK] {tier}/index.html updated (new md5: {new_md5})")

    # Update service-worker.js revision
    if os.path.exists(sw_path):
        with open(sw_path, 'r', encoding='utf-8') as f:
            sw = f.read()

        # Replace the index.html revision
        old_rev_match = re.search(r'(url:"\.\/index\.html",revision:")([^"]+)(")', sw)
        if old_rev_match:
            old_rev = old_rev_match.group(2)
            sw = sw.replace(
                f'url:"./index.html",revision:"{old_rev}"',
                f'url:"./index.html",revision:"{new_md5}"'
            )
            with open(sw_path, 'w', encoding='utf-8', newline='') as f:
                f.write(sw)
            print(f"  [OK] {tier}/service-worker.js revision updated ({old_rev[:8]}.. -> {new_md5[:8]}..)")
        else:
            print(f"  [WARN] Could not find index.html revision in {sw_path}")
    else:
        print(f"  [WARN] {sw_path} not found")

    return True


def main():
    print("=" * 60)
    print("ICS Compass — CSS Override Injection")
    print("=" * 60)
    print()

    success = 0
    for tier in TIERS:
        print(f"[{tier}]")
        if inject_css(tier):
            success += 1
        print()

    print(f"Done: {success}/{len(TIERS)} tiers updated")
    print()

    # Verify no "伦理" in any compiled JS
    print("Verifying '伦理' not present in compiled bundles...")
    for tier in TIERS:
        js_dir = os.path.join(BASE, tier, 'js')
        if os.path.isdir(js_dir):
            for fname in os.listdir(js_dir):
                if fname.endswith('.js') and not fname.endswith('.map'):
                    fpath = os.path.join(js_dir, fname)
                    with open(fpath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    lun = content.count('伦理')
                    zhi = content.count('治理')
                    status = "[OK]" if lun == 0 else "[FAIL]"
                    print(f"  {status} {tier}/{fname}: 伦理={lun}, 治理={zhi}")


if __name__ == '__main__':
    main()

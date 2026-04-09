#!/usr/bin/env python3
"""
Batch inject Compass/星际罗盘 nav link into all ICS website HTML files.
Finds <ul class="nav-links">...</ul> and inserts a new <li> before </ul>.
"""
import os
import re
import sys

BASE = r"C:\Users\Administrator\Documents\ics-website\public"

# Compass link for EN and ZH pages
COMPASS_EN = '<li><a href="/compass/" class="nav-link">Compass</a></li>'
COMPASS_ZH = '<li><a href="/compass/" class="nav-link">星际罗盘</a></li>'


def is_zh_page(filepath):
    """Determine if a page is Chinese based on path or content."""
    norm = filepath.replace("\\", "/")
    # Path-based detection
    if "/zh/" in norm:
        return True
    # Check for ZH template files
    if "template-zh" in norm:
        return True
    return False


def get_compass_li(filepath, indent="                "):
    """Return the appropriate compass <li> tag with proper indentation."""
    if is_zh_page(filepath):
        return f"{indent}{COMPASS_ZH}"
    else:
        return f"{indent}{COMPASS_EN}"


def already_has_compass(content):
    """Check if compass link already exists."""
    return '/compass/' in content and ('Compass</a>' in content or '星际罗盘</a>' in content)


def inject_compass(filepath):
    """Inject compass nav link into a single HTML file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Skip if already has compass link
    if already_has_compass(content):
        return "SKIP (already has Compass)"

    # Find <ul class="nav-links"> ... </ul> pattern
    # We need to insert before the closing </ul> of the nav-links
    pattern = re.compile(
        r'(<ul\s+class="nav-links">\s*)'   # opening tag
        r'(.*?)'                             # nav items
        r'(\s*</ul>)',                       # closing tag
        re.DOTALL
    )

    match = pattern.search(content)
    if not match:
        return "SKIP (no nav-links found)"

    # Determine indentation from existing <li> items
    nav_content = match.group(2)
    li_match = re.search(r'^(\s*)<li>', nav_content, re.MULTILINE)
    indent = li_match.group(1) if li_match else "                "

    compass_li = get_compass_li(filepath, indent)

    # Insert before </ul>
    # Find the last </li> and add after it
    new_nav = match.group(1) + match.group(2).rstrip() + "\n" + compass_li + match.group(3)
    new_content = content[:match.start()] + new_nav + content[match.end():]

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)

    return "OK"


def main():
    count_ok = 0
    count_skip = 0
    count_error = 0

    # Collect all HTML files
    html_files = []

    for root, dirs, files in os.walk(BASE):
        # Skip compass directory itself
        if "compass" in root.replace("\\", "/").split("/"):
            continue
        for fname in files:
            if fname.endswith('.html'):
                html_files.append(os.path.join(root, fname))

    # Also add template files outside public/
    templates_dir = os.path.join(BASE, "..", "templates")
    if os.path.isdir(templates_dir):
        for root, dirs, files in os.walk(templates_dir):
            for fname in files:
                if fname.endswith('.html'):
                    html_files.append(os.path.join(root, fname))

    # Also check daily-commenary templates
    dc_templates = os.path.join(BASE, "..", "daily-commenary", "templates")
    if os.path.isdir(dc_templates):
        for root, dirs, files in os.walk(dc_templates):
            for fname in files:
                if fname.endswith('.html'):
                    html_files.append(os.path.join(root, fname))

    print(f"Found {len(html_files)} HTML files to process\n")

    for filepath in sorted(html_files):
        rel = os.path.relpath(filepath, os.path.dirname(BASE))
        try:
            result = inject_compass(filepath)
            if result == "OK":
                count_ok += 1
                print(f"  ✓ {rel}")
            else:
                count_skip += 1
                print(f"  - {rel}: {result}")
        except Exception as e:
            count_error += 1
            print(f"  ✗ {rel}: ERROR - {e}")

    print(f"\nDone: {count_ok} injected, {count_skip} skipped, {count_error} errors")
    return 0 if count_error == 0 else 1


if __name__ == "__main__":
    sys.exit(main())

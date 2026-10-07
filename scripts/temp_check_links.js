const fs = require('fs');
const path = require('path');

const root = path.resolve('public');
const scanRoots = [
  path.join(root, 'en'),
  path.join(root, 'zh'),
  path.join(root, 'index.html'),
  path.join(root, '404.html'),
  path.join(root, 'admin')
];

function listHtmlFiles(targetPath, bucket) {
  if (!fs.existsSync(targetPath)) {
    return;
  }
  const stat = fs.statSync(targetPath);
  if (stat.isFile()) {
    if (targetPath.endsWith('.html')) {
      bucket.push(targetPath);
    }
    return;
  }
  for (const entry of fs.readdirSync(targetPath, { withFileTypes: true })) {
    const fullPath = path.join(targetPath, entry.name);
    if (entry.isDirectory()) {
      listHtmlFiles(fullPath, bucket);
    } else if (entry.isFile() && entry.name.endsWith('.html')) {
      bucket.push(fullPath);
    }
  }
}

function extractRefs(html) {
  const refs = [];
  const attrPattern = /<(?:a|img|link|script|source|iframe)\b[^>]*?\s(?:href|src)="([^"]+)"[^>]*>/gi;
  let match;
  while ((match = attrPattern.exec(html)) !== null) {
    refs.push(match[1]);
  }
  return refs;
}

function normalizeRef(filePath, ref) {
  if (!ref || /^(https?:|mailto:|tel:|data:|javascript:|#)/i.test(ref)) {
    return null;
  }
  const clean = decodeURIComponent(ref.split('?')[0].split('#')[0]);
  if (!clean) {
    return null;
  }
  if (clean.startsWith('/')) {
    return path.join(root, clean.slice(1));
  }
  return path.resolve(path.dirname(filePath), clean);
}

const htmlFiles = [];
for (const item of scanRoots) {
  listHtmlFiles(item, htmlFiles);
}

const issues = [];
for (const filePath of htmlFiles) {
  const html = fs.readFileSync(filePath, 'utf8');
  for (const ref of extractRefs(html)) {
    const resolved = normalizeRef(filePath, ref);
    if (!resolved) {
      continue;
    }
    if (!fs.existsSync(resolved)) {
      issues.push({
        file: path.relative(root, filePath).replace(/\\/g, '/'),
        ref,
        resolved: path.relative(root, resolved).replace(/\\/g, '/')
      });
    }
  }
}

for (const issue of issues.slice(0, 250)) {
  console.log([issue.file, issue.ref, issue.resolved].join('\t'));
}
console.log(`ISSUE_COUNT\t${issues.length}`);

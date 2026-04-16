/**
 * ICS Compass — License Gate
 * Protects paid tiers (Pro / Academic / Enterprise) with license key verification.
 * 
 * Usage: Add <script src="../js/license-gate.js"></script> at the END of <body> in paid tier index.html
 * The script reads window.__ICS_TIER__ to determine the current tier.
 * 
 * License Key Format:  ICS-{TIER}-{8 hex chars}-{2 char checksum}
 *   Example: ICS-PRO-A3F8C210-7B
 * 
 * Storage: localStorage key = "ics_license_{tier}"
 */
(function () {
  'use strict';

  // ─── Configuration ────────────────────────────────────────────
  const TIER = (window.__ICS_TIER__ || '').toLowerCase();
  const FREE_TIER = 'free';

  // If it's free tier or tier is not set, don't gate
  if (!TIER || TIER === FREE_TIER) return;

  // Payment Links — replace with real Stripe Payment Links after setup
  const PAYMENT_LINKS = {
    pro: 'https://buy.stripe.com/actual-pro-link',
    academic: 'https://buy.stripe.com/actual-academic-link',
    enterprise: 'https://buy.stripe.com/actual-enterprise-link'
  };

  const TIER_DISPLAY = {
    pro:        { en: 'Pro', zh: '专业版', color: '#a78bfa', price: '$19.99/mo · ¥128/月' },
    academic:   { en: 'Academic', zh: '学术版', color: '#f59e0b', price: '$39.99/mo · ¥258/月' },
    enterprise: { en: 'Enterprise', zh: '企业版', color: '#c084fc', price: 'Custom / 定制报价' }
  };

  // ─── License Key Validation ───────────────────────────────────
  function computeChecksum(prefix) {
    var sum = 0;
    for (var i = 0; i < prefix.length; i++) {
      sum = ((sum << 5) - sum + prefix.charCodeAt(i)) & 0xFFFF;
    }
    return ((sum & 0xFF) ^ 0x5A).toString(16).toUpperCase().padStart(2, '0');
  }

  function validateLicenseKey(key, tier) {
    if (!key || typeof key !== 'string') return false;
    key = key.trim().toUpperCase();

    // Format: ICS-TIER-XXXXXXXX-CC
    var pattern = /^ICS-([A-Z]+)-([0-9A-F]{8})-([0-9A-F]{2})$/;
    var match = key.match(pattern);
    if (!match) return false;

    var keyTier = match[1].toLowerCase();
    var body = match[2];
    var checksum = match[3];

    // Tier must match (enterprise key works for all, academic works for pro+academic)
    var tierLevel = { pro: 1, academic: 2, enterprise: 3 };
    var keyLevel = tierLevel[keyTier] || 0;
    var requiredLevel = tierLevel[tier] || 99;
    if (keyLevel < requiredLevel) return false;

    // Verify checksum
    var prefix = 'ICS-' + match[1] + '-' + body;
    var expectedChecksum = computeChecksum(prefix);
    return checksum === expectedChecksum;
  }

  function getStoredKey(tier) {
    try { return localStorage.getItem('ics_license_' + tier) || ''; }
    catch (e) { return ''; }
  }

  function storeKey(tier, key) {
    try { localStorage.setItem('ics_license_' + tier, key.trim().toUpperCase()); }
    catch (e) { /* silent */ }
  }

  // ─── Check: already activated? ────────────────────────────────
  var storedKey = getStoredKey(TIER);
  if (storedKey && validateLicenseKey(storedKey, TIER)) {
    // Already activated — let the app load
    return;
  }

  // Also check higher-tier keys (enterprise key unlocks everything)
  var higherTiers = ['enterprise', 'academic', 'pro'];
  for (var t = 0; t < higherTiers.length; t++) {
    if (higherTiers[t] === TIER) continue;
    var hk = getStoredKey(higherTiers[t]);
    if (hk && validateLicenseKey(hk, TIER)) return;
  }

  // ─── Not activated — build gate overlay ───────────────────────
  var info = TIER_DISPLAY[TIER] || TIER_DISPLAY.pro;
  var payLink = PAYMENT_LINKS[TIER] || '#';

  // Hide the app content
  var appRoot = document.getElementById('root') || document.getElementById('app');
  if (appRoot) appRoot.style.display = 'none';

  // Create overlay
  var overlay = document.createElement('div');
  overlay.id = 'ics-license-gate';
  overlay.innerHTML = [
    '<div class="lg-backdrop"></div>',
    '<div class="lg-modal">',
    '  <div class="lg-logo">',
    '    <svg viewBox="0 0 44 44" fill="none" width="64" height="64">',
    '      <circle cx="22" cy="22" r="20" stroke="rgba(167,139,250,0.3)" stroke-width="1" fill="none"/>',
    '      <circle cx="22" cy="22" r="13" stroke="rgba(6,182,212,0.25)" stroke-width="1" fill="none"/>',
    '      <circle cx="22" cy="22" r="5" fill="' + info.color + '"/>',
    '    </svg>',
    '  </div>',
    '  <h1 class="lg-title">ICS COMPASS ' + info.en.toUpperCase() + '</h1>',
    '  <p class="lg-subtitle">星际罗盘 ' + info.zh + '</p>',
    '  <p class="lg-price">' + info.price + '</p>',
    '  <div class="lg-divider"></div>',
    '',
    '  <div class="lg-section">',
    '    <h2>🔑 Activate License / 激活许可</h2>',
    '    <p class="lg-desc">Enter your license key below. You will receive it by email after purchase.<br>请在下方输入您的许可密钥。购买后将通过邮件发送给您。</p>',
    '    <div class="lg-input-group">',
    '      <input type="text" id="lg-key-input" placeholder="ICS-' + TIER.toUpperCase() + '-XXXXXXXX-XX" spellcheck="false" autocomplete="off">',
    '      <button id="lg-activate-btn">Activate 激活</button>',
    '    </div>',
    '    <p id="lg-error" class="lg-error" style="display:none"></p>',
    '  </div>',
    '',
    '  <div class="lg-divider"></div>',
    '',
    '  <div class="lg-section">',
    '    <h2>🛒 Purchase / 购买</h2>',
    '    <p class="lg-desc">Get instant access with a subscription. Cancel anytime.<br>订阅即可立即使用，随时取消。</p>',
    '    <a href="' + payLink + '" target="_blank" class="lg-buy-btn" id="lg-buy-btn">',
    '      Subscribe to ' + info.en + ' / 订阅' + info.zh,
    '    </a>',
    (TIER === 'enterprise' ?
      '    <p class="lg-note">Or contact us: <a href="mailto:franka328162810@gmail.com">franka328162810@gmail.com</a></p>' :
      ''),
    '  </div>',
    '',
    '  <div class="lg-footer">',
    '    <a href="../" class="lg-back">← Back to Editions / 返回版本选择</a>',
    '    <span class="lg-sep">|</span>',
    '    <a href="../free/" class="lg-free-link">Try Free Edition / 试用免费版 →</a>',
    '  </div>',
    '</div>'
  ].join('\n');

  // Inject styles
  var style = document.createElement('style');
  style.textContent = [
    '#ics-license-gate { position:fixed; top:0; left:0; width:100%; height:100%; z-index:99999; display:flex; align-items:center; justify-content:center; }',
    '.lg-backdrop { position:absolute; top:0; left:0; width:100%; height:100%; background:linear-gradient(135deg,#0a1628 0%,#0f1d32 50%,#050a14 100%); }',
    '.lg-modal { position:relative; z-index:1; max-width:520px; width:90%; background:rgba(15,25,50,0.85); backdrop-filter:blur(20px); -webkit-backdrop-filter:blur(20px); border:1px solid rgba(167,139,250,0.2); border-radius:16px; padding:2.5rem; text-align:center; box-shadow:0 20px 60px rgba(0,0,0,0.6),0 0 40px rgba(124,58,237,0.15); }',
    '.lg-logo { margin-bottom:1.5rem; }',
    '.lg-title { font-family:"Orbitron",sans-serif; font-size:1.5rem; font-weight:700; color:#f1f5f9; letter-spacing:0.08em; margin-bottom:0.3rem; }',
    '.lg-subtitle { font-family:"Noto Sans SC","Space Grotesk",sans-serif; font-size:1rem; color:rgba(255,255,255,0.6); margin-bottom:0.3rem; }',
    '.lg-price { font-size:1.125rem; color:' + info.color + '; font-weight:600; margin-bottom:1rem; }',
    '.lg-divider { height:1px; background:rgba(167,139,250,0.15); margin:1.5rem 0; }',
    '.lg-section h2 { font-family:"Space Grotesk","Orbitron",sans-serif; font-size:1rem; font-weight:600; color:#f1f5f9; letter-spacing:0.03em; margin-bottom:0.75rem; }',
    '.lg-desc { font-size:0.875rem; color:rgba(255,255,255,0.6); line-height:1.7; margin-bottom:1rem; }',
    '.lg-input-group { display:flex; gap:0.5rem; }',
    '.lg-input-group input { flex:1; padding:0.75rem 1rem; background:rgba(255,255,255,0.05); border:1px solid rgba(167,139,250,0.25); border-radius:8px; color:#f1f5f9; font-size:0.95rem; font-family:monospace; outline:none; transition:border-color 0.2s; }',
    '.lg-input-group input:focus { border-color:' + info.color + '; }',
    '.lg-input-group input::placeholder { color:rgba(255,255,255,0.3); }',
    '#lg-activate-btn { padding:0.75rem 1.5rem; background:linear-gradient(135deg,' + info.color + ',#06b6d4); color:#fff; border:none; border-radius:8px; font-weight:600; font-size:0.9rem; cursor:pointer; transition:transform 0.2s,box-shadow 0.2s; white-space:nowrap; }',
    '#lg-activate-btn:hover { transform:translateY(-1px); box-shadow:0 4px 16px rgba(124,58,237,0.4); }',
    '.lg-error { color:#ef4444; font-size:0.85rem; margin-top:0.75rem; }',
    '.lg-buy-btn { display:inline-block; padding:0.875rem 2rem; background:linear-gradient(135deg,' + info.color + ',#06b6d4); color:#fff; text-decoration:none; border-radius:10px; font-weight:600; font-size:0.95rem; letter-spacing:0.02em; transition:transform 0.2s,box-shadow 0.2s; }',
    '.lg-buy-btn:hover { transform:translateY(-2px); box-shadow:0 8px 24px rgba(124,58,237,0.4); }',
    '.lg-note { font-size:0.8rem; color:rgba(255,255,255,0.5); margin-top:0.75rem; }',
    '.lg-note a { color:' + info.color + '; text-decoration:none; }',
    '.lg-footer { margin-top:1.5rem; padding-top:1rem; border-top:1px solid rgba(167,139,250,0.1); display:flex; justify-content:center; gap:1rem; flex-wrap:wrap; }',
    '.lg-back, .lg-free-link { color:rgba(255,255,255,0.5); text-decoration:none; font-size:0.85rem; transition:color 0.2s; }',
    '.lg-back:hover, .lg-free-link:hover { color:' + info.color + '; }',
    '.lg-sep { color:rgba(255,255,255,0.2); }',
    '@media(max-width:540px) { .lg-modal { padding:1.5rem; } .lg-input-group { flex-direction:column; } .lg-title { font-size:1.2rem; } }'
  ].join('\n');

  document.head.appendChild(style);
  document.body.appendChild(overlay);

  // ─── Event handlers ───────────────────────────────────────────
  var input = document.getElementById('lg-key-input');
  var btn = document.getElementById('lg-activate-btn');
  var errorEl = document.getElementById('lg-error');

  function tryActivate() {
    var key = (input.value || '').trim();
    if (!key) {
      errorEl.textContent = 'Please enter a license key. / 请输入许可密钥。';
      errorEl.style.display = 'block';
      return;
    }
    if (validateLicenseKey(key, TIER)) {
      storeKey(TIER, key);
      // Success — remove gate, show app
      overlay.remove();
      style.remove();
      if (appRoot) appRoot.style.display = '';
      // Also reload to ensure React mounts cleanly
      window.location.reload();
    } else {
      errorEl.textContent = 'Invalid license key. Please check and try again. / 许可密钥无效，请检查后重试。';
      errorEl.style.display = 'block';
      input.style.borderColor = '#ef4444';
      setTimeout(function () { input.style.borderColor = ''; }, 2000);
    }
  }

  btn.addEventListener('click', tryActivate);
  input.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') tryActivate();
    errorEl.style.display = 'none';
  });

  // Auto-uppercase input
  input.addEventListener('input', function () {
    var pos = input.selectionStart;
    input.value = input.value.toUpperCase();
    input.setSelectionRange(pos, pos);
  });

  // Check URL params for activation (for email links: ?key=ICS-PRO-XXXXXXXX-XX)
  try {
    var urlParams = new URLSearchParams(window.location.search);
    var urlKey = urlParams.get('key');
    if (urlKey && validateLicenseKey(urlKey, TIER)) {
      storeKey(TIER, urlKey);
      // Remove ?key param and reload
      var cleanUrl = window.location.href.split('?')[0] + window.location.hash;
      window.location.replace(cleanUrl);
    }
  } catch (e) { /* silent — old browsers */ }

})();

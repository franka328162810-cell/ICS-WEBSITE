/**
 * ICS Compass — Stripe Webhook Handler (Cloudflare Worker)
 * 
 * This worker:
 * 1. Receives Stripe checkout.session.completed webhooks
 * 2. Generates a license key for the purchased tier
 * 3. Sends the license key to the customer's email via Mailchannels (free on CF Workers)
 * 4. Stores the license record in KV for audit trail
 * 
 * Environment Variables (set in Cloudflare Dashboard):
 *   STRIPE_WEBHOOK_SECRET  — Stripe webhook signing secret (whsec_...)
 *   STRIPE_SECRET_KEY      — Stripe secret key (sk_live_... or sk_test_...)
 *   ICS_LICENSES           — KV Namespace binding for storing license records
 * 
 * Deployment:
 *   1. Install Wrangler CLI: npm install -g wrangler
 *   2. wrangler login
 *   3. Create KV namespace: wrangler kv:namespace create "ICS_LICENSES"
 *   4. Update wrangler.toml with the KV ID
 *   5. Set secrets: wrangler secret put STRIPE_WEBHOOK_SECRET
 *                   wrangler secret put STRIPE_SECRET_KEY
 *   6. Deploy: wrangler deploy
 */

// ─── License Key Generation ─────────────────────────────────────
// Must match the validation logic in license-gate.js and activate.html

function computeChecksum(prefix) {
  let sum = 0;
  for (let i = 0; i < prefix.length; i++) {
    sum = ((sum << 5) - sum + prefix.charCodeAt(i)) & 0xFFFF;
  }
  return ((sum & 0xFF) ^ 0x5A).toString(16).toUpperCase().padStart(2, '0');
}

function generateLicenseKey(tier) {
  // Generate 8 random hex characters
  const array = new Uint8Array(4);
  crypto.getRandomValues(array);
  const body = Array.from(array).map(b => b.toString(16).toUpperCase().padStart(2, '0')).join('');

  const prefix = `ICS-${tier.toUpperCase()}-${body}`;
  const checksum = computeChecksum(prefix);

  return `${prefix}-${checksum}`;
}

// ─── Stripe Webhook Signature Verification ──────────────────────

async function verifyStripeSignature(payload, signature, secret) {
  const parts = signature.split(',').reduce((acc, part) => {
    const [key, value] = part.split('=');
    acc[key] = value;
    return acc;
  }, {});

  const timestamp = parts['t'];
  const expectedSig = parts['v1'];

  if (!timestamp || !expectedSig) return false;

  // Verify timestamp is within 5 minutes
  const now = Math.floor(Date.now() / 1000);
  if (Math.abs(now - parseInt(timestamp)) > 300) return false;

  // Compute expected signature
  const signedPayload = `${timestamp}.${payload}`;
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  const sig = await crypto.subtle.sign('HMAC', key, encoder.encode(signedPayload));
  const computed = Array.from(new Uint8Array(sig)).map(b => b.toString(16).padStart(2, '0')).join('');

  return computed === expectedSig;
}

// ─── Stripe Product → Tier Mapping ──────────────────────────────
// Set these to your actual Stripe Price IDs after creating products

const PRICE_TO_TIER = {
  'price_REPLACE_PRO':        'pro',
  'price_REPLACE_ACADEMIC':   'academic',
  'price_REPLACE_ENTERPRISE': 'enterprise',
};

function tierFromLineItems(lineItems) {
  if (!lineItems || !lineItems.data) return null;
  for (const item of lineItems.data) {
    const priceId = item.price?.id;
    if (priceId && PRICE_TO_TIER[priceId]) {
      return PRICE_TO_TIER[priceId];
    }
  }
  return null;
}

// ─── Email Sending via MailChannels (free on CF Workers) ────────

async function sendLicenseEmail(email, tier, licenseKey, customerName) {
  const tierNames = {
    pro: 'Pro 专业版',
    academic: 'Academic 学术版',
    enterprise: 'Enterprise 企业版'
  };

  const tierName = tierNames[tier] || tier;
  const activateUrl = `https://ics-studies.org/compass/activate.html?tier=${tier}&key=${encodeURIComponent(licenseKey)}`;
  const directUrl = `https://ics-studies.org/compass/${tier}/?key=${encodeURIComponent(licenseKey)}`;

  const htmlBody = `
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body style="font-family: 'Segoe UI', Arial, sans-serif; background: #0a1628; color: #f1f5f9; padding: 2rem;">
  <div style="max-width: 560px; margin: 0 auto; background: rgba(15,25,50,0.98); border: 1px solid rgba(167,139,250,0.2); border-radius: 12px; padding: 2rem;">
    <div style="text-align: center; margin-bottom: 1.5rem;">
      <h1 style="font-size: 1.5rem; letter-spacing: 0.08em; color: #a78bfa;">ICS COMPASS</h1>
      <p style="color: rgba(255,255,255,0.6);">License Key / 许可密钥</p>
    </div>

    <p>Dear ${customerName || 'Valued Customer'},</p>
    <p>Thank you for subscribing to <strong>ICS Compass ${tierName}</strong>!</p>
    <p>感谢您订阅 <strong>ICS 星际罗盘 ${tierName}</strong>！</p>

    <div style="background: rgba(167,139,250,0.1); border: 1px solid rgba(167,139,250,0.3); border-radius: 8px; padding: 1.5rem; margin: 1.5rem 0; text-align: center;">
      <p style="font-size: 0.85rem; color: rgba(255,255,255,0.5); margin-bottom: 0.5rem;">Your License Key / 您的许可密钥:</p>
      <p style="font-family: 'Courier New', monospace; font-size: 1.25rem; font-weight: 700; color: #f1f5f9; letter-spacing: 0.08em; word-break: break-all;">
        ${licenseKey}
      </p>
    </div>

    <p><strong>Quick Activate / 快速激活:</strong></p>
    <p><a href="${activateUrl}" style="color: #a78bfa;">Click here to activate automatically / 点击此处自动激活</a></p>
    <p>Or open ICS Compass ${tierName} directly:<br>
    <a href="${directUrl}" style="color: #06b6d4;">${directUrl}</a></p>

    <hr style="border: none; border-top: 1px solid rgba(167,139,250,0.15); margin: 1.5rem 0;">

    <p style="font-size: 0.85rem; color: rgba(255,255,255,0.5);">
      If you have any questions, contact us at: 
      <a href="mailto:franka328162810@gmail.com" style="color: #a78bfa;">franka328162810@gmail.com</a>
    </p>
    <p style="font-size: 0.85rem; color: rgba(255,255,255,0.5);">
      © 2026 Interstellar Civilization Studies. All rights reserved.
    </p>
  </div>
</body>
</html>`;

  const textBody = `ICS COMPASS — License Key

Dear ${customerName || 'Valued Customer'},

Thank you for subscribing to ICS Compass ${tierName}!

Your License Key: ${licenseKey}

Quick Activate: ${activateUrl}

Or go directly to: ${directUrl}

Questions? Contact: franka328162810@gmail.com

© 2026 Interstellar Civilization Studies`;

  // Send via MailChannels API (free for Cloudflare Workers)
  const response = await fetch('https://api.mailchannels.net/tx/v1/send', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      personalizations: [{
        to: [{ email: email, name: customerName || '' }],
      }],
      from: {
        email: 'noreply@ics-studies.org',
        name: 'ICS Compass'
      },
      subject: `Your ICS Compass ${tierName} License Key / 您的ICS星际罗盘${tierName}许可密钥`,
      content: [
        { type: 'text/plain', value: textBody },
        { type: 'text/html', value: htmlBody }
      ],
    }),
  });

  return response.ok;
}

// ─── Fetch line items from Stripe ───────────────────────────────

async function fetchLineItems(sessionId, stripeKey) {
  const response = await fetch(
    `https://api.stripe.com/v1/checkout/sessions/${sessionId}/line_items`,
    {
      headers: {
        'Authorization': `Bearer ${stripeKey}`,
      },
    }
  );
  if (!response.ok) return null;
  return await response.json();
}

// ─── Main Handler ───────────────────────────────────────────────

export default {
  async fetch(request, env) {
    // Only accept POST
    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }

    // Read body
    const payload = await request.text();
    const signature = request.headers.get('Stripe-Signature');

    if (!signature) {
      return new Response('Missing signature', { status: 400 });
    }

    // Verify webhook signature
    const isValid = await verifyStripeSignature(payload, signature, env.STRIPE_WEBHOOK_SECRET);
    if (!isValid) {
      return new Response('Invalid signature', { status: 401 });
    }

    // Parse event
    const event = JSON.parse(payload);

    // Only handle checkout.session.completed
    if (event.type !== 'checkout.session.completed') {
      return new Response('OK — event type ignored', { status: 200 });
    }

    const session = event.data.object;
    const customerEmail = session.customer_details?.email || session.customer_email;
    const customerName = session.customer_details?.name || '';

    if (!customerEmail) {
      console.error('No customer email found in session:', session.id);
      return new Response('OK — no email', { status: 200 });
    }

    // Fetch line items to determine tier
    const lineItems = await fetchLineItems(session.id, env.STRIPE_SECRET_KEY);
    const tier = tierFromLineItems(lineItems);

    if (!tier) {
      console.error('Could not determine tier for session:', session.id);
      return new Response('OK — unknown tier', { status: 200 });
    }

    // Generate license key
    const licenseKey = generateLicenseKey(tier);

    // Store in KV for audit trail
    if (env.ICS_LICENSES) {
      const record = {
        licenseKey,
        tier,
        email: customerEmail,
        name: customerName,
        sessionId: session.id,
        customerId: session.customer,
        subscriptionId: session.subscription,
        amountTotal: session.amount_total,
        currency: session.currency,
        createdAt: new Date().toISOString(),
      };
      await env.ICS_LICENSES.put(
        `license:${licenseKey}`,
        JSON.stringify(record),
        { expirationTtl: 365 * 24 * 60 * 60 } // 1 year
      );
      // Also index by email
      const existingKeys = await env.ICS_LICENSES.get(`email:${customerEmail}`);
      const keys = existingKeys ? JSON.parse(existingKeys) : [];
      keys.push(licenseKey);
      await env.ICS_LICENSES.put(`email:${customerEmail}`, JSON.stringify(keys));
    }

    // Send email
    const emailSent = await sendLicenseEmail(customerEmail, tier, licenseKey, customerName);
    console.log(`License generated: ${licenseKey} for ${customerEmail} (${tier}), email sent: ${emailSent}`);

    return new Response(JSON.stringify({
      success: true,
      tier,
      email: customerEmail,
      emailSent,
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  },
};

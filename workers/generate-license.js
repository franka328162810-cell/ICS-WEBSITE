/**
 * ICS Compass — License Key Generator (Admin Tool)
 * 
 * Run this script with Node.js to generate valid license keys:
 *   node generate-license.js pro
 *   node generate-license.js academic
 *   node generate-license.js enterprise
 *   node generate-license.js pro 5        (generate 5 keys)
 * 
 * Generated keys can be:
 *   1. Sent manually to customers before Stripe automation is set up
 *   2. Used for testing the license gate
 *   3. Given to beta testers / reviewers
 */

const crypto = require('crypto');

function computeChecksum(prefix) {
  let sum = 0;
  for (let i = 0; i < prefix.length; i++) {
    sum = ((sum << 5) - sum + prefix.charCodeAt(i)) & 0xFFFF;
  }
  return ((sum & 0xFF) ^ 0x5A).toString(16).toUpperCase().padStart(2, '0');
}

function generateLicenseKey(tier) {
  const body = crypto.randomBytes(4).toString('hex').toUpperCase();
  const prefix = `ICS-${tier.toUpperCase()}-${body}`;
  const checksum = computeChecksum(prefix);
  return `${prefix}-${checksum}`;
}

// ─── CLI ────────────────────────────────────────────────────────
const tier = (process.argv[2] || '').toLowerCase();
const count = parseInt(process.argv[3]) || 1;

const validTiers = ['pro', 'academic', 'enterprise'];

if (!validTiers.includes(tier)) {
  console.log('ICS Compass — License Key Generator');
  console.log('====================================');
  console.log('');
  console.log('Usage:');
  console.log('  node generate-license.js <tier> [count]');
  console.log('');
  console.log('Tiers:');
  console.log('  pro         — $19.99/mo (unlocks Pro features)');
  console.log('  academic    — $39.99/mo (unlocks Academic + Pro)');
  console.log('  enterprise  — Custom    (unlocks all tiers)');
  console.log('');
  console.log('Examples:');
  console.log('  node generate-license.js pro');
  console.log('  node generate-license.js academic 3');
  console.log('  node generate-license.js enterprise 10');
  process.exit(1);
}

console.log(`\nICS Compass ${tier.toUpperCase()} License Key${count > 1 ? 's' : ''}:`);
console.log('─'.repeat(45));

for (let i = 0; i < count; i++) {
  const key = generateLicenseKey(tier);
  console.log(`  ${key}`);
}

console.log('─'.repeat(45));
console.log(`\nActivation URL format:`);
console.log(`  https://ics-studies.org/compass/activate.html?tier=${tier}&key=<KEY>`);
console.log(`  https://ics-studies.org/compass/${tier}/?key=<KEY>`);
console.log('');

if (tier === 'enterprise') {
  console.log('Note: Enterprise keys unlock ALL tiers (Pro + Academic + Enterprise).');
} else if (tier === 'academic') {
  console.log('Note: Academic keys also unlock Pro tier.');
}
console.log('');

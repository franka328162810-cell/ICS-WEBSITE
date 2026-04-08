/**
 * ICS Mobile Navigation — hamburger menu + full-screen overlay
 * Self-contained: injects its own CSS and DOM elements.
 * Works with any page structure that has .navbar > .nav-container > .nav-links
 * 
 * Created 2026-04-08  —  ICS Website Repair Batch 2
 */
(function () {
  'use strict';

  // Only run once
  if (document.querySelector('.ics-hamburger')) return;

  var navbar = document.querySelector('.navbar');
  var navLinks = document.querySelector('.nav-links');
  if (!navbar || !navLinks) return;

  // ──────────────────────────────────────
  //  1.  Inject CSS
  // ──────────────────────────────────────
  var css = document.createElement('style');
  css.id = 'ics-mobile-nav-css';
  css.textContent = [
    /* ── hamburger button ── */
    '.ics-hamburger{',
    '  display:none;flex-direction:column;justify-content:center;align-items:center;',
    '  gap:5px;width:38px;height:38px;background:none;',
    '  border:1px solid rgba(167,139,250,.3);border-radius:8px;',
    '  cursor:pointer;padding:6px;transition:all .3s ease;z-index:1100;',
    '  position:relative;',
    '}',
    '.ics-hamburger:hover{border-color:rgba(167,139,250,.6);}',
    '.ics-hamburger span{',
    '  display:block;width:20px;height:2px;background:rgba(255,255,255,.85);',
    '  border-radius:2px;transition:all .3s ease;',
    '}',
    /* animated X when open */
    '.ics-hamburger.active span:nth-child(1){transform:translateY(7px) rotate(45deg);}',
    '.ics-hamburger.active span:nth-child(2){opacity:0;}',
    '.ics-hamburger.active span:nth-child(3){transform:translateY(-7px) rotate(-45deg);}',

    /* ── overlay ── */
    '.ics-mobile-overlay{',
    '  display:none;position:fixed;inset:0;',
    '  background:rgba(8,18,38,.97);backdrop-filter:blur(24px);-webkit-backdrop-filter:blur(24px);',
    '  z-index:1050;flex-direction:column;align-items:center;justify-content:center;',
    '  gap:1rem;padding:2rem 1.5rem;overflow-y:auto;',
    '}',
    '.ics-mobile-overlay.active{display:flex;}',

    /* links inside overlay */
    '.ics-mobile-overlay a{',
    '  font-size:1.2rem;font-weight:500;color:rgba(255,255,255,.82);',
    '  text-decoration:none;padding:.7rem 2.5rem;border-radius:10px;',
    '  transition:all .25s ease;text-align:center;letter-spacing:.3px;',
    '  width:100%;max-width:320px;',
    '}',
    '.ics-mobile-overlay a:hover,.ics-mobile-overlay a.active{',
    '  color:#a78bfa;background:rgba(167,139,250,.1);',
    '}',

    /* divider between nav links and actions */
    '.ics-mobile-overlay .ics-mob-divider{',
    '  width:60px;height:1px;background:rgba(167,139,250,.25);margin:.5rem 0;',
    '}',

    /* lock body scroll */
    'body.ics-menu-open{overflow:hidden;}',

    /* ── responsive: show hamburger when nav-links would be hidden ── */
    '@media(max-width:1024px){',
    '  .ics-hamburger{display:flex;}',
    '}',
  ].join('\n');
  document.head.appendChild(css);

  // ──────────────────────────────────────
  //  2.  Create hamburger button
  // ──────────────────────────────────────
  var hamburger = document.createElement('button');
  hamburger.className = 'ics-hamburger';
  hamburger.setAttribute('aria-label', 'Toggle navigation menu');
  hamburger.setAttribute('aria-expanded', 'false');
  hamburger.innerHTML = '<span></span><span></span><span></span>';

  // Insert as first child of .nav-actions (before search icon)
  var navActions = navbar.querySelector('.nav-actions');
  if (navActions) {
    navActions.insertBefore(hamburger, navActions.firstChild);
  } else {
    // Fallback: append to nav-container
    var navContainer = navbar.querySelector('.nav-container');
    if (navContainer) navContainer.appendChild(hamburger);
  }

  // ──────────────────────────────────────
  //  3.  Create overlay menu
  // ──────────────────────────────────────
  var overlay = document.createElement('div');
  overlay.className = 'ics-mobile-overlay';
  overlay.setAttribute('role', 'dialog');
  overlay.setAttribute('aria-label', 'Navigation menu');

  // Clone nav links
  var links = navLinks.querySelectorAll('a');
  for (var i = 0; i < links.length; i++) {
    var a = links[i].cloneNode(true);
    overlay.appendChild(a);
  }

  // Add divider
  var divider = document.createElement('div');
  divider.className = 'ics-mob-divider';
  overlay.appendChild(divider);

  // Clone nav-actions links (language switch + contact)
  if (navActions) {
    var langBtns = navActions.querySelectorAll('.lang-switch a');
    for (var j = 0; j < langBtns.length; j++) {
      var lb = langBtns[j].cloneNode(true);
      lb.style.fontSize = '1rem';
      lb.style.padding = '.5rem 1.5rem';
      lb.style.display = 'inline-block';
      lb.style.width = 'auto';
      overlay.appendChild(lb);
    }
    var contactLink = navActions.querySelector('.nav-contact');
    if (contactLink) {
      var cl = contactLink.cloneNode(true);
      cl.className = '';
      overlay.appendChild(cl);
    }
  }

  document.body.appendChild(overlay);

  // ──────────────────────────────────────
  //  4.  Toggle logic
  // ──────────────────────────────────────
  function openMenu() {
    hamburger.classList.add('active');
    hamburger.setAttribute('aria-expanded', 'true');
    overlay.classList.add('active');
    document.body.classList.add('ics-menu-open');
  }

  function closeMenu() {
    hamburger.classList.remove('active');
    hamburger.setAttribute('aria-expanded', 'false');
    overlay.classList.remove('active');
    document.body.classList.remove('ics-menu-open');
  }

  hamburger.addEventListener('click', function (e) {
    e.stopPropagation();
    if (overlay.classList.contains('active')) {
      closeMenu();
    } else {
      openMenu();
    }
  });

  // Close when a link is tapped
  overlay.addEventListener('click', function (e) {
    if (e.target.tagName === 'A') {
      closeMenu();
    }
  });

  // Close on Escape key
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && overlay.classList.contains('active')) {
      closeMenu();
    }
  });

  // Close when resized back to desktop
  var mq = window.matchMedia('(min-width: 1025px)');
  function onDesktop(e) {
    if (e.matches) closeMenu();
  }
  if (mq.addEventListener) {
    mq.addEventListener('change', onDesktop);
  } else if (mq.addListener) {
    mq.addListener(onDesktop);   // Safari < 14
  }
})();

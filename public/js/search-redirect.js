/**
 * ICS Nav Search Redirect
 * Makes the .nav-search button functional on all pages by redirecting
 * to the research-archive search page.
 * 
 * Created 2026-04-09  —  ICS Website Repair Batch 3
 */
(function () {
  'use strict';

  var searchBtn = document.querySelector('.nav-search');
  if (!searchBtn) return;

  // Already has a handler (e.g. research-archive page with inline search)
  if (searchBtn.getAttribute('onclick')) return;

  // Detect language from <html lang> or URL path
  var lang = 'en';
  var htmlLang = document.documentElement.lang || '';
  var path = window.location.pathname;

  if (htmlLang.indexOf('zh') !== -1 || path.indexOf('/zh/') !== -1) {
    lang = 'zh';
  }

  var searchPage = lang === 'zh'
    ? '/zh/研究归档.html'
    : '/en/research-archive.html';

  searchBtn.addEventListener('click', function (e) {
    e.preventDefault();
    e.stopPropagation();
    window.location.href = searchPage;
  });

  // Add a title/tooltip so users know it's clickable
  searchBtn.title = lang === 'zh' ? '站内搜索' : 'Search';

  function getSearchBasePath() {
    const htmlLang = document.documentElement.lang || '';
    const path = window.location.pathname || '';
    if (htmlLang.indexOf('zh') !== -1 || path.indexOf('/zh/') === 0) {
      return '/zh/';
    }
    return '/en/';
  }

  function normalizeSearchHref(href) {
    if (!href) return href;
    if (href.startsWith('/') || href.startsWith('http://') || href.startsWith('https://') || href.startsWith('#')) {
      return href;
    }
    try {
      const base = window.location.origin + getSearchBasePath();
      const normalizedUrl = new URL(href, base);
      return normalizedUrl.pathname + normalizedUrl.search + normalizedUrl.hash;
    } catch (err) {
      return href;
    }
  }

  function normalizeSearchResultLinks(root = document) {
    const links = root.querySelectorAll('.search-results a[href]');
    links.forEach(link => {
      const href = link.getAttribute('href');
      const normalized = normalizeSearchHref(href);
      if (normalized !== href) {
        link.setAttribute('href', normalized);
      }
    });
  }

  function observeSearchResults() {
    const container = document.querySelector('.search-results');
    if (!container) return;

    normalizeSearchResultLinks(container);

    const observer = new MutationObserver((mutations) => {
      mutations.forEach(mutation => {
        if (mutation.type === 'childList' || mutation.type === 'subtree') {
          normalizeSearchResultLinks(container);
        }
      });
    });

    observer.observe(container, { childList: true, subtree: true });
  }

  observeSearchResults();
})();

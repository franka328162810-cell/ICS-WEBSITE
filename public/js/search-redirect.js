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
})();

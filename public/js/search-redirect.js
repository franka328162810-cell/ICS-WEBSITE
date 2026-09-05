/**
 * ICS Nav Search Redirect
 * Makes the .nav-search button functional on all pages by redirecting
 * to the research-archive search page.
 * 
 * Created 2026-04-09  —  ICS Website Repair Batch 3
 */
(function () {
  'use strict';

  var localeConfig = {
    en: {
      basePath: '/en/',
      searchPage: '/en/research-archive.html',
      topLevelPages: {
        'about.html': true,
        'academic-dialogue.html': true,
        'ai-assistant.html': true,
        'ai-governance.html': true,
        'applications.html': true,
        'book-overview.html': true,
        'cdi.html': true,
        'contact-us.html': true,
        'crv.html': true,
        'csia.html': true,
        'daily-commentary.html': true,
        'existential-risk-management.html': true,
        'forbidden-red-lines.html': true,
        'in-depth-research.html': true,
        'index.html': true,
        'institutions.html': true,
        'intergenerational-governance.html': true,
        'mbcl.html': true,
        'metrics.html': true,
        'negentropy-responsibility-principle.html': true,
        'new-cognition.html': true,
        'new-cosmology.html': true,
        'new-life-view.html': true,
        'new-three-views.html': true,
        'newsletter.html': true,
        'news-archive.html': true,
        'normative-principles.html': true,
        'privacy.html': true,
        'publication-information.html': true,
        'recursive-freedom-principle.html': true,
        'research-agenda.html': true,
        'research-archive.html': true,
        'resources.html': true,
        'reversibility-principle.html': true,
        'rfd.html': true,
        'space-governance.html': true,
        'terms.html': true,
        'ucs.html': true,
        'work-volume-one.html': true,
        'work-volume-two.html': true,
        'work-volume-three.html': true,
        'work-volume-four.html': true
      },
      aliases: {
        'contact.html': 'contact-us.html',
        'deep-research.html': 'in-depth-research.html',
        'publications.html': 'book-overview.html'
      }
    },
    zh: {
      basePath: '/zh/',
      searchPage: '/zh/研究归档.html',
      topLevelPages: {
        'privacy.html': true,
        'terms.html': true,
        'in-depth-research.html': true,
        'daily-commentary.html': true,
        'crispr-breakthrough-2026-04-16.html': true,
        '与人工智能安全研究的对话.html': true,
        '与国际空间法的对话.html': true,
        '与环境伦理学的对话.html': true,
        '与长期主义的对话.html': true,
        '专著第一卷.html': true,
        '专著第三卷.html': true,
        '专著第二卷.html': true,
        '专著第四卷.html': true,
        '人工智能助手.html': true,
        '人工智能治理.html': true,
        '代际治理.html': true,
        '关于星际文明学.html': true,
        '出版信息.html': true,
        '制度设计.html': true,
        '可逆性原则.html': true,
        '太空治理.html': true,
        '存在风险管理.html': true,
        '学术对话.html': true,
        '宇宙尺度影响评估.html': true,
        '宇宙意识标度.html': true,
        '应用领域概述.html': true,
        '承诺可逆可验证性.html': true,
        '指标体系.html': true,
        '文明发展指数.html': true,
        '新三观概述.html': true,
        '新宇宙观.html': true,
        '新生命观.html': true,
        '新认知观.html': true,
        '模因生物安全等级.html': true,
        '每日热点评论.html': true,
        '每日热点评论归档.html': true,
        '深度研究.html': true,
        '研究归档.html': true,
        '研究议程.html': true,
        '禁忌红线.html': true,
        '联系我们.html': true,
        '著作概述.html': true,
        '规范原则概述.html': true,
        '订阅通讯.html': true,
        '负熵责任原则.html': true,
        '资源.html': true,
        '递归自由原则.html': true,
        '递归自由度.html': true,
        '首页.html': true
      },
      aliases: {}
    }
  };

  function getLocaleKey() {
    var htmlLang = document.documentElement.lang || '';
    var path = window.location.pathname || '';
    if (htmlLang.indexOf('zh') !== -1 || path.indexOf('/zh/') === 0) {
      return 'zh';
    }
    return 'en';
  }

  function getLocaleSettings() {
    return localeConfig[getLocaleKey()] || localeConfig.en;
  }

  function splitHref(href) {
    var cleanHref = (href || '').trim();
    var hashIndex = cleanHref.indexOf('#');
    var queryIndex = cleanHref.indexOf('?');
    var cutIndex = cleanHref.length;

    if (queryIndex !== -1 && queryIndex < cutIndex) {
      cutIndex = queryIndex;
    }
    if (hashIndex !== -1 && hashIndex < cutIndex) {
      cutIndex = hashIndex;
    }

    return {
      path: cleanHref.slice(0, cutIndex),
      suffix: cleanHref.slice(cutIndex)
    };
  }

  function normalizeHref(href) {
    var cleanHref = (href || '').trim();
    if (!cleanHref) return cleanHref;
    if (/^(https?:|mailto:|tel:|data:|javascript:|#)/i.test(cleanHref)) {
      return cleanHref;
    }
    if (cleanHref.indexOf('/cdn-cgi/') === 0) {
      return cleanHref;
    }

    var hrefParts = splitHref(cleanHref);
    var pathOnly = hrefParts.path;
    var suffix = hrefParts.suffix;
    var locale = getLocaleSettings();

    if (pathOnly.indexOf('../en/') === 0 || pathOnly.indexOf('../zh/') === 0) {
      return '/' + pathOnly.slice(3) + suffix;
    }

    if (pathOnly.indexOf('/en/') === 0 || pathOnly.indexOf('/zh/') === 0 || pathOnly.indexOf('/') === 0) {
      return pathOnly + suffix;
    }

    if (pathOnly.indexOf('/') === -1) {
      var targetFile = locale.aliases[pathOnly] || pathOnly;
      if (locale.topLevelPages[targetFile]) {
        return locale.basePath + targetFile + suffix;
      }
    }

    return cleanHref;
  }

  function normalizeAnchors(root) {
    var anchors = (root || document).querySelectorAll('a[href]');
    anchors.forEach(function (anchor) {
      var href = anchor.getAttribute('href');
      var normalized = normalizeHref(href);
      if (normalized && normalized !== href) {
        anchor.setAttribute('href', normalized);
      }
    });
  }

  function normalizeSearchResultLinks(root = document) {
    const links = root.querySelectorAll('.search-results a[href]');
    links.forEach(link => {
      const href = link.getAttribute('href');
      const normalized = normalizeHref(href);
      if (normalized !== href) {
        link.setAttribute('href', normalized);
      }
    });
  }

  normalizeAnchors(document);

  var searchBtn = document.querySelector('.nav-search');
  if (searchBtn && !searchBtn.getAttribute('onclick')) {
    var locale = getLocaleSettings();

    searchBtn.addEventListener('click', function (e) {
      e.preventDefault();
      e.stopPropagation();
      window.location.href = locale.searchPage;
    });

    searchBtn.title = getLocaleKey() === 'zh' ? '站内搜索' : 'Search';
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
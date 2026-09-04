(function () {
  'use strict';

  if (window.ICSSubscribe) {
    return;
  }

  var DEFAULT_CONFIG = {
    endpoint: '',
    timeoutMs: 8000,
    contactEmail: 'ics@interstellar-civilization.org'
  };

  var MESSAGES = {
    en: {
      invalid: 'Please enter a valid email address.',
      success: 'Your subscription request has been submitted. Please check your inbox for confirmation.',
      unconfigured: 'Secure email subscription is not configured on this deployment yet. Please contact {email} directly.',
      network: 'We could not submit your subscription request right now. Please contact {email} directly.'
    },
    zh: {
      invalid: '请输入有效的邮箱地址。',
      success: '订阅请求已提交，请留意后续确认邮件。',
      unconfigured: '当前部署尚未启用安全的服务器端订阅功能，请直接联系 {email}。',
      network: '暂时无法提交订阅请求，请直接联系 {email}。'
    }
  };

  function pickLang(lang) {
    return lang === 'en' ? 'en' : 'zh';
  }

  function formatMessage(template, email) {
    return template.replace('{email}', email);
  }

  function normalizePayload(payload) {
    var next = Object.assign({}, payload);
    next.email = typeof next.email === 'string' ? next.email.trim() : '';
    next.name = typeof next.name === 'string' ? next.name.trim() : '';
    return next;
  }

  function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  function isSecureEndpoint(url) {
    if (!url || typeof url !== 'string') return false;
    if (url.indexOf('https://') === 0) return true;
    return url.indexOf('http://localhost') === 0 || url.indexOf('http://127.0.0.1') === 0;
  }

  async function submit(payload, overrides) {
    var cfg = Object.assign({}, DEFAULT_CONFIG, window.ICS_SUBSCRIBE_CONFIG || {}, overrides || {});
    var data = normalizePayload(payload || {});
    var lang = pickLang(cfg.lang || data.lang || 'en');
    var t = MESSAGES[lang];

    if (!isValidEmail(data.email)) {
      return { ok: false, code: 'invalid', message: t.invalid };
    }

    if (!cfg.endpoint || !isSecureEndpoint(cfg.endpoint)) {
      return {
        ok: false,
        code: 'unconfigured',
        message: formatMessage(t.unconfigured, cfg.contactEmail)
      };
    }

    var controller = typeof AbortController === 'function' ? new AbortController() : null;
    var timer = null;

    if (controller) {
      timer = window.setTimeout(function () {
        controller.abort();
      }, cfg.timeoutMs);
    }

    try {
      var response = await fetch(cfg.endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data),
        signal: controller ? controller.signal : undefined
      });

      if (timer) {
        window.clearTimeout(timer);
      }

      if (!response.ok) {
        return {
          ok: false,
          code: 'network',
          message: formatMessage(t.network, cfg.contactEmail)
        };
      }

      return { ok: true, code: 'success', message: t.success };
    } catch (_) {
      if (timer) {
        window.clearTimeout(timer);
      }

      return {
        ok: false,
        code: 'network',
        message: formatMessage(t.network, cfg.contactEmail)
      };
    }
  }

  window.ICSSubscribe = {
    submit: submit
  };
})();
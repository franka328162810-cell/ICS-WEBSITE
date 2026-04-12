(function () {
    const AUTH_KEY = 'ics_admin_session_v1';

    // Authentication is handled server-side. This client module
    // only manages the local session token returned by the server.

    function setSession(payload) {
        localStorage.setItem(AUTH_KEY, JSON.stringify({
            ...payload,
            loginAt: new Date().toISOString()
        }));
        return payload;
    }

    function getSession() {
        try {
            const raw = localStorage.getItem(AUTH_KEY);
            return raw ? JSON.parse(raw) : null;
        } catch {
            return null;
        }
    }

    function clearSession() {
        localStorage.removeItem(AUTH_KEY);
    }

    function login(email, password) {
        // [已隐藏] 真实环境请实现服务端认证接口，演示环境已禁用后台入口。
        // console.warn('CMS authentication requires server-side setup. See admin docs.');
        return null;
    }

    function logout() {
        clearSession();
        window.location.href = '/admin/login.html';
    }

    // function requireAuth() {
        const session = getSession();
        if (!session) {
            window.location.href = '/admin/login.html';
            return null;
        }
        return session;
    }

    window.ICSAuth = {
        login,
        logout,
        getSession,
        // requireAuth
    };
})();

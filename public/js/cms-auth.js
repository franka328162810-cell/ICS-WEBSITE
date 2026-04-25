(function () {
    const AUTH_KEY = 'ics_admin_session_v1';
    const DISABLED_MESSAGE = 'Secure CMS login is disabled until server-side authentication is configured.';
    const adminConfig = window.ICS_ADMIN_CONFIG || {};
    const isAdminEnabled = adminConfig.enabled === true;

    // Authentication is handled server-side. This client module
    // only manages the local session token returned by the server.

    function getSession() {
        if (!isAdminEnabled) return null;
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
        void email;
        void password;
        clearSession();
        return {
            ok: false,
            reason: 'disabled',
            message: DISABLED_MESSAGE
        };
    }

    function logout() {
        clearSession();
        window.location.href = '/admin/login.html';
    }

    function requireAuth() {
        if (!isAdminEnabled) {
            clearSession();
            window.location.href = '/admin/login.html';
            return null;
        }
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
        requireAuth,
        isEnabled: () => isAdminEnabled
    };
})();

(function () {
    const AUTH_KEY = 'ics_admin_session_v1';

    const DEMO_USERS = [
        {
            email: 'admin@ics-studies.org',
            password: 'ICS2026!',
            role: 'admin',
            name: 'ICS Admin'
        }
    ];

    function setSession(user) {
        const payload = {
            email: user.email,
            role: user.role,
            name: user.name,
            loginAt: new Date().toISOString()
        };
        localStorage.setItem(AUTH_KEY, JSON.stringify(payload));
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
        const user = DEMO_USERS.find(u => u.email === email && u.password === password);
        if (!user) return null;
        return setSession(user);
    }

    function logout() {
        clearSession();
        window.location.href = '/admin/login.html';
    }

    function requireAuth() {
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
        requireAuth
    };
})();

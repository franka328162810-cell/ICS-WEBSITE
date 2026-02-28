/**
 * ICS Website Common JavaScript
 * 星际文明学网站公共脚本
 */

// ==========================================
// Navigation Functions
// ==========================================

/**
 * 处理导航栏滚动效果
 */
function handleNavScroll() {
    const navbar = document.getElementById('navbar');
    if (!navbar) return;

    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });
}

/**
 * 平滑滚动到锚点
 */
function smoothScroll() {
    const links = document.querySelectorAll('a[href^="#"]');
    links.forEach(link => {
        link.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

/**
 * 设置当前页面导航高亮
 */
function setActiveNavigation() {
    const currentPage = document.body.getAttribute('data-page');
    const navLinks = document.querySelectorAll('.nav-link');

    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href && href.includes(currentPage)) {
            link.classList.add('active');
        }
    });
}

// ==========================================
// Card Interactions
// ==========================================

/**
 * 初始化卡片悬停效果
 */
function initCardHover() {
    const cards = document.querySelectorAll('.content-card, .table-card, .framework-diagram, .mission-card');
    cards.forEach(card => {
        card.addEventListener('mouseenter', function () {
            this.style.transform = 'translateY(-4px)';
        });
        card.addEventListener('mouseleave', function () {
            this.style.transform = 'translateY(0)';
        });
    });
}

/**
 * 初始化按钮点击效果
 */
function initButtonEffects() {
    const buttons = document.querySelectorAll('.concept-btn, .link-item');
    buttons.forEach(button => {
        button.addEventListener('click', function (e) {
            // 创建涟漪效果
            const ripple = document.createElement('span');
            const rect = this.getBoundingClientRect();
            const size = Math.max(rect.width, rect.height);
            const x = e.clientX - rect.left - size / 2;
            const y = e.clientY - rect.top - size / 2;
            ripple.style.cssText = `
                position: absolute;
                width: ${size}px;
                height: ${size}px;
                left: ${x}px;
                top: ${y}px;
                background: rgba(167, 139, 250, 0.3);
                border-radius: 50%;
                transform: scale(0);
                animation: ripple 0.6s ease-out;pointer-events: none;
            `;

            this.style.position = 'relative';
            this.style.overflow = 'hidden';
            this.appendChild(ripple);

            setTimeout(() => {
                ripple.remove();
            }, 600);
        });
    });

    // 添加涟漪动画CSS
    if (!document.querySelector('#ripple-animation')) {
        const style = document.createElement('style');
        style.id = 'ripple-animation';
        style.textContent = `
            @keyframes ripple {
                to {
                    transform: scale(2);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
    }
}

// ==========================================
// Search Functionality
// ==========================================

/**
 * 初始化搜索功能
 */
function initSearch() {
    const searchBtn = document.querySelector('.nav-search');
    if (!searchBtn) return;

    searchBtn.addEventListener('click', function () {
        // 这里可以添加搜索模态框或跳转到搜索页面
        console.log('Search clicked');
        // 临时实现：显示搜索提示
        showNotification('搜索功能即将上线', 'info');
    });
}

// ==========================================
// Language Switching
// ==========================================

/**
 * 处理语言切换
 */
function handleLanguageSwitch() {
    const langBtns = document.querySelectorAll('.lang-btn');
    langBtns.forEach(btn => {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            const targetUrl = this.getAttribute('href');
            // 添加切换动画
            document.body.style.opacity = '0.8';
            document.body.style.transition = 'opacity 0.3s ease';

            setTimeout(() => {
                window.location.href = targetUrl;
            }, 300);
        });
    });
}

// ==========================================
// Utility Functions
// ==========================================

/**
 * 显示通知消息
 */
function showNotification(message, type = 'info', duration = 3000) {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    // 样式
    notification.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        padding: 12px 24px;
        background: ${type === 'info' ? 'rgba(124, 58, 237, 0.9)' : 'rgba(245, 158, 11, 0.9)'};
        color: white;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
        z-index: 10000;
        transform: translateX(100%);
        transition: transform 0.3s ease;
        backdrop-filter: blur(10px);border: 1px solid rgba(255, 255, 255, 0.1);
    `;

    document.body.appendChild(notification);

    // 显示动画
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 100);

    // 自动隐藏
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, duration);
}

/**
 * 检测设备类型
 */
function detectDevice() {
    const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    const isTablet = /iPad|Android/i.test(navigator.userAgent) && window.innerWidth >= 768;

    document.body.classList.add(isMobile ? 'mobile' : 'desktop');
    if (isTablet) document.body.classList.add('tablet');

    return { isMobile, isTablet };
}

/**
 * 处理图片懒加载
 */
function initLazyLoading() {
    const images = document.querySelectorAll('img[data-src]');

    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.classList.remove('lazy');
                    imageObserver.unobserve(img);
                }
            });
        });

        images.forEach(img => imageObserver.observe(img));
    } else {
        // 降级处理
        images.forEach(img => {
            img.src = img.dataset.src;
        });
    }
}

/**
 * 处理页面加载动画
 */
function handlePageLoad() {
    window.addEventListener('load', () => {
        document.body.style.opacity = '1';
        document.body.style.transition = 'opacity 0.5s ease';

        // 触发页面加载完成事件
        const event = new CustomEvent('pageLoaded');
        document.dispatchEvent(event);
    });
}

/**
 * 处理错误
 */
function handleErrors() {
    window.addEventListener('error', (e) => {
        console.error('页面错误:', e.error);
        // 可以在这里添加错误上报逻辑
    });

    window.addEventListener('unhandledrejection', (e) => {
        console.error('未处理的Promise拒绝:', e.reason);
        // 可以在这里添加错误上报逻辑
    });
}

// ==========================================
// Performance Optimization
// ==========================================

/**
 * 防抖函数
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * 节流函数
 */
function throttle(func, limit) {
    let inThrottle;
    return function () {
        const args = arguments;
        const context = this;
        if (!inThrottle) {
            func.apply(context, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// ==========================================
// Initialization
// ==========================================

/**
 * 初始化所有功能
 */
function initializeWebsite() {
    // 基础功能
    handleNavScroll();
    smoothScroll();
    setActiveNavigation();

    // 交互功能
    initCardHover();
    initButtonEffects();
    initSearch();
    handleLanguageSwitch();

    // 工具功能
    detectDevice();
    initLazyLoading();
    handlePageLoad();
    handleErrors();

    // 性能优化
    const debouncedResize = debounce(() => {
        // 处理窗口大小变化
        const event = new CustomEvent('windowResized');
        document.dispatchEvent(event);
    }, 250);

    window.addEventListener('resize', debouncedResize);

    console.log('ICS Website initialized successfully');
}

// DOM加载完成后初始化
document.addEventListener('DOMContentLoaded', initializeWebsite);

// 导出常用函数供其他脚本使用
window.ICS = {
    showNotification,
    debounce,
    throttle,
    detectDevice
};

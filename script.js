// 等待DOM加载完成
document.addEventListener('DOMContentLoaded', function() {
    // 清理可能存在的旧移动菜单和下拉内容
    cleanupPreviousMenu();
    
    // 首先初始化下拉菜单
    initDropdowns();
    
    // 滚动效果
    initScrollEffects();
    
    // 移动端导航菜单
    initMobileNav();
    
    // 为所有工具图标添加错误处理
    document.querySelectorAll('.tool-icon').forEach(img => {
        img.onerror = function() {
            // 设置默认占位符图标
            this.src = 'images/default-tool-icon.png';
            // 防止无限循环
            this.onerror = null;
        };
    });
    
    // 视频教程权限控制
    controlVideoAccess();
});

// 清理之前可能存在的菜单
function cleanupPreviousMenu() {
    // 移除页面上可能已存在的下拉内容
    document.querySelectorAll('.dropdown-content').forEach(menu => {
        menu.remove();
    });
    
    // 移除可能已经存在的移动菜单
    document.querySelectorAll('.mobile-menu').forEach(menu => {
        menu.remove();
    });
    
    // 移除移动菜单按钮
    document.querySelectorAll('.mobile-menu-btn').forEach(btn => {
        btn.remove();
    });
    
    // 恢复body状态
    document.body.classList.remove('menu-open');
}

// 初始化下拉菜单
function initDropdowns() {
    // 修改选择器，只针对header中的dropdown元素
    const dropdowns = document.querySelectorAll('.header .main-nav .dropdown');
    
    dropdowns.forEach(dropdown => {
        const link = dropdown.querySelector('.nav-link');
        
        // 创建下拉内容
        const dropdownContent = document.createElement('div');
        dropdownContent.className = 'dropdown-content';
        
        // 根据不同的导航项添加不同的下拉内容
        if (link.textContent.includes('AI工具')) {
            dropdownContent.innerHTML = `
                <a href="ai-tools.html#tools">AI工具列表</a>
                <a href="ai-tools.html#reviews">工具评测</a>
                <a href="ai-tools.html#guides">使用指南</a>
                <a href="ai-tools.html#comparison">工具对比</a>
            `;
        } else if (link.textContent.includes('跨境电商')) {
            dropdownContent.innerHTML = `
                <a href="ecommerce.html#amazon">亚马逊</a>
                <a href="ecommerce.html#tiktok">TikTok Shop</a>
                <a href="ecommerce.html#shopify">Shopify</a>
                <a href="ecommerce.html#strategies">运营策略</a>
            `;
        } else if (link.textContent.includes('视频教程')) {
            dropdownContent.innerHTML = `
                <a href="courses.html#beginner">入门课程</a>
                <a href="courses.html#advanced">进阶课程</a>
                <a href="courses.html#masterclass">大师课</a>
                <a href="courses.html#live">直播回放</a>
            `;
        }
        
        dropdown.appendChild(dropdownContent);
        
        // 添加鼠标经过事件监听
        dropdown.addEventListener('mouseenter', function() {
            dropdownContent.style.display = 'block';
            setTimeout(() => {
                dropdownContent.style.opacity = '1';
                dropdownContent.style.transform = 'translateY(0)';
            }, 10);
        });
        
        dropdown.addEventListener('mouseleave', function() {
            dropdownContent.style.opacity = '0';
            dropdownContent.style.transform = 'translateY(-10px)';
            setTimeout(() => {
                dropdownContent.style.display = 'none';
            }, 300);
        });
    });
}

// 初始化滚动效果
function initScrollEffects() {
    // 滚动时导航栏效果
    let lastScrollTop = 0;
    const header = document.querySelector('.header');
    
    window.addEventListener('scroll', function() {
        let scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        
        if (scrollTop > lastScrollTop && scrollTop > 100) {
            // 向下滚动超过100px
            header.style.transform = 'translateY(-100%)';
        } else {
            // 向上滚动或者在顶部
            header.style.transform = 'translateY(0)';
        }
        
        // 根据滚动位置改变导航栏样式
        if (scrollTop > 50) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
        
        lastScrollTop = scrollTop;
    });
    
    // 滚动动画效果
    const animateElements = document.querySelectorAll('.category-card, .article-card, .plan-card, .vip-info');
    
    // 检查元素是否在视口内
    function isInViewport(element) {
        const rect = element.getBoundingClientRect();
        return (
            rect.top <= (window.innerHeight || document.documentElement.clientHeight) &&
            rect.bottom >= 0
        );
    }
    
    // 初始隐藏需要动画的元素
    animateElements.forEach(element => {
        element.style.opacity = '0';
        element.style.transform = 'translateY(20px)';
        element.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    });
    
    // 滚动时检查并触发动画
    function checkScroll() {
        animateElements.forEach(element => {
            if (isInViewport(element) && element.style.opacity === '0') {
                setTimeout(() => {
                    element.style.opacity = '1';
                    element.style.transform = 'translateY(0)';
                }, 100);
            }
        });
    }
    
    // 页面加载和滚动时触发动画
    window.addEventListener('load', checkScroll);
    window.addEventListener('scroll', checkScroll);
}

// 初始化移动端导航
function initMobileNav() {
    // 检查是否已有移动菜单，避免重复创建
    if (document.querySelector('.mobile-menu')) {
        return;
    }
    
    // 创建移动端菜单按钮
    const header = document.querySelector('.header .container');
    const mobileMenuBtn = document.createElement('div');
    mobileMenuBtn.className = 'mobile-menu-btn';
    mobileMenuBtn.innerHTML = `
        <span></span>
        <span></span>
        <span></span>
    `;
    header.appendChild(mobileMenuBtn);
    
    // 创建移动端菜单
    const mobileMenu = document.createElement('div');
    mobileMenu.className = 'mobile-menu';
    
    // 复制导航链接到移动端菜单
    const navLinks = document.querySelectorAll('.header .main-nav .nav-link');
    const mobileNavContent = document.createElement('div');
    mobileNavContent.className = 'mobile-nav-content';
    
    navLinks.forEach(link => {
        const linkClone = link.cloneNode(true);
        const menuItem = document.createElement('div');
        menuItem.className = 'mobile-menu-item';
        menuItem.appendChild(linkClone);
        
        // 如果是下拉菜单，添加展开功能
        if (link.parentElement.classList.contains('dropdown')) {
            const subMenu = document.createElement('div');
            subMenu.className = 'mobile-submenu';
            
            // 使用相同的下拉内容逻辑构建子菜单
            if (link.textContent.includes('AI工具')) {
                subMenu.innerHTML = `
                    <a href="ai-tools.html#tools">AI工具列表</a>
                    <a href="ai-tools.html#reviews">工具评测</a>
                    <a href="ai-tools.html#guides">使用指南</a>
                    <a href="ai-tools.html#comparison">工具对比</a>
                `;
            } else if (link.textContent.includes('跨境电商')) {
                subMenu.innerHTML = `
                    <a href="ecommerce.html#amazon">亚马逊</a>
                    <a href="ecommerce.html#tiktok">TikTok Shop</a>
                    <a href="ecommerce.html#shopify">Shopify</a>
                    <a href="ecommerce.html#strategies">运营策略</a>
                `;
            } else if (link.textContent.includes('视频教程')) {
                subMenu.innerHTML = `
                    <a href="courses.html#beginner">入门课程</a>
                    <a href="courses.html#advanced">进阶课程</a>
                    <a href="courses.html#masterclass">大师课</a>
                    <a href="courses.html#live">直播回放</a>
                `;
            }
            
            menuItem.appendChild(subMenu);
            
            // 添加点击展开功能
            linkClone.addEventListener('click', function(e) {
                e.preventDefault();
                subMenu.classList.toggle('active');
            });
        }
        
        mobileNavContent.appendChild(menuItem);
    });
    
    mobileMenu.appendChild(mobileNavContent);
    
    // 添加认证按钮到移动菜单
    const authButtons = document.querySelector('.header .auth-buttons').cloneNode(true);
    authButtons.className = 'mobile-auth-buttons';
    mobileMenu.appendChild(authButtons);
    
    document.body.appendChild(mobileMenu);
    
    // 移动菜单开关功能
    mobileMenuBtn.addEventListener('click', function() {
        this.classList.toggle('active');
        mobileMenu.classList.toggle('active');
        document.body.classList.toggle('menu-open');
    });
    
    // 点击外部关闭菜单
    document.addEventListener('click', function(e) {
        if (mobileMenu.classList.contains('active') && 
            !mobileMenu.contains(e.target) && 
            !mobileMenuBtn.contains(e.target)) {
            mobileMenuBtn.classList.remove('active');
            mobileMenu.classList.remove('active');
            document.body.classList.remove('menu-open');
        }
    });
    
    // 响应式调整
    window.addEventListener('resize', function() {
        if (window.innerWidth > 768 && mobileMenu.classList.contains('active')) {
            mobileMenuBtn.classList.remove('active');
            mobileMenu.classList.remove('active');
            document.body.classList.remove('menu-open');
        }
    });
}

// 添加视频播放功能
function initVideoPlayer() {
    const videoThumbnails = document.querySelectorAll('.video-thumbnail');
    
    videoThumbnails.forEach(thumbnail => {
        thumbnail.addEventListener('click', function() {
            const videoId = this.dataset.videoId;
            const videoContainer = this.parentElement;
            
            // 创建iframe替换缩略图
            const iframe = document.createElement('iframe');
            iframe.src = `https://www.youtube.com/embed/${videoId}?autoplay=1`;
            iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
            iframe.setAttribute('allowfullscreen', '');
            iframe.className = 'video-iframe';
            
            // 替换缩略图
            videoContainer.innerHTML = '';
            videoContainer.appendChild(iframe);
        });
    });
}

// 添加电子邮件订阅功能
document.addEventListener('DOMContentLoaded', function() {
    const newsletterForm = document.querySelector('.newsletter-form');
    
    if (newsletterForm) {
        newsletterForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const emailInput = this.querySelector('input[type="email"]');
            const email = emailInput.value.trim();
            
            if (email && validateEmail(email)) {
                // 模拟订阅成功
                emailInput.value = '';
                
                // 创建成功提示
                const successMessage = document.createElement('div');
                successMessage.className = 'newsletter-success';
                successMessage.textContent = '订阅成功！感谢您的关注。';
                
                // 在表单后插入成功提示
                this.parentNode.appendChild(successMessage);
                
                // 5秒后移除提示
                setTimeout(() => {
                    successMessage.style.opacity = '0';
                    setTimeout(() => {
                        successMessage.remove();
                    }, 500);
                }, 5000);
            } else {
                // 显示错误提示
                emailInput.classList.add('error');
                setTimeout(() => {
                    emailInput.classList.remove('error');
                }, 1000);
            }
        });
    }
});

// 邮箱验证函数
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

// 会员权限检查
function checkMembershipAccess() {
    // 从localStorage获取会员状态
    const isMember = localStorage.getItem('isMember') === 'true';
    return isMember;
}

// 视频教程权限控制
function controlVideoAccess() {
    const videoElements = document.querySelectorAll('.video-tutorial');
    const isMember = checkMembershipAccess();
    
    videoElements.forEach(video => {
        if (!isMember) {
            // 非会员显示提示信息
            const placeholder = document.createElement('div');
            placeholder.className = 'video-placeholder';
            placeholder.innerHTML = `
                <div class="membership-required">
                    <h3>会员专享内容</h3>
                    <p>开通会员即可观看完整视频教程</p>
                    <a href="membership.html" class="btn btn-primary">立即开通会员</a>
                </div>
            `;
            video.parentNode.replaceChild(placeholder, video);
        }
    });
} 
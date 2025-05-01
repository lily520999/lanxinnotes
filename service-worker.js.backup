// Service Worker 版本
const CACHE_VERSION = 'v1.2';
const CACHE_NAME = `lanxin-cache-${CACHE_VERSION}`;

// 需要缓存的资源列表
const urlsToCache = [
  '/',
  '/index.html',
  '/hot-courses.html',
  '/styles.css',
  '/script.js',
  '/images/lanxin-logo.png',
  '/images/ai-tools.png',
  '/images/ecommerce.png',
  '/images/video-courses.jpg',
  '/images/bilibili-logo.png'
];

// 安装 Service Worker 并缓存核心资源
self.addEventListener('install', event => {
  console.log('Service Worker 安装中...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('缓存资源中...');
        
        // 尝试缓存所有资源，但跳过失败的缓存
        const cachePromises = urlsToCache.map(url => {
          // 使用绝对路径，这样在自定义域名下也能正常工作
          const absoluteUrl = new URL(url, self.location.origin).href;
          return fetch(absoluteUrl, { 
            mode: 'no-cors',  // 添加跨域支持
            credentials: 'same-origin'
          })
          .then(response => {
            if(response.status === 200) {
              return cache.put(absoluteUrl, response);
            } else {
              console.log(`缓存 ${absoluteUrl} 失败: ${response.status}`);
              return Promise.resolve();
            }
          })
          .catch(error => {
            console.log(`缓存 ${absoluteUrl} 出错: ${error.message}`);
            return Promise.resolve();
          });
        });
        
        // 返回一个Promise，即使部分资源加载失败，也不会影响Service Worker安装
        return Promise.all(cachePromises);
      })
  );
  
  // 立即激活
  self.skipWaiting();
});

// 激活时清理旧缓存
self.addEventListener('activate', event => {
  console.log('Service Worker 激活中...');
  
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('清理旧缓存:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('Service Worker 现在控制所有页面');
      return self.clients.claim();
    })
  );
});

// 拦截请求并提供缓存响应
self.addEventListener('fetch', event => {
  console.log('Service Worker: 拦截请求', event.request.url);
  
  // 处理导航请求
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request).catch(() => {
        return caches.match('/index.html');
      })
    );
    return;
  }
  
  // 对于其他资源，先尝试网络，网络失败时使用缓存
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // 复制响应，因为响应只能使用一次
        const responseToCache = response.clone();
        
        // 如果是有效响应，则更新缓存
        if (response.status === 200) {
          caches.open(CACHE_NAME)
            .then(cache => {
              cache.put(event.request, responseToCache);
            });
        }
        
        return response;
      })
      .catch(() => {
        // 网络请求失败时，尝试从缓存中获取
        return caches.match(event.request)
          .then(cachedResponse => {
            if (cachedResponse) {
              return cachedResponse;
            }
            
            // 如果是HTML请求，并且没有缓存，则返回index.html
            if (event.request.url.match(/\.html$/) || event.request.url.endsWith('/')) {
              return caches.match('/index.html');
            }
            
            // 对于不在缓存中的资源，尝试提供一个占位符或默认响应
            if (event.request.url.match(/\.(jpg|jpeg|png|gif|svg)$/i)) {
              return fetch('https://via.placeholder.com/300');
            }
            
            // 对于其他资源，返回简单的404响应
            return new Response('资源未找到', {
              status: 404,
              headers: { 'Content-Type': 'text/plain' }
            });
          });
      })
  );
}); 
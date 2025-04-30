// 兰心运营笔记 Service Worker
const CACHE_NAME = 'lanxin-cache-v1';

// 需要缓存的静态资源
const STATIC_ASSETS = [
  './',
  './index.html',
  './styles.css',
  './script.js',
  './ai-tools.css',
  './content-creation.css',
  './ecommerce.css',
  './membership.css',
  './images/lanxin-logo.png',
  './images/ai-tools.png',
  './images/ecommerce.png',
  './images/video-courses.jpg',
  './images/youtube-logo.png',
  './images/n1. wechat-pay.png',
  './images/n2. alipay.png',
  './images/n3. wechat-qr.png',
  './images/n4. alipay-qr.png'
];

// 安装 Service Worker
self.addEventListener('install', event => {
  console.log('Service Worker 安装中...');
  
  // 预缓存静态资源
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('缓存静态资源中...');
        return cache.addAll(STATIC_ASSETS);
      })
      .then(() => {
        console.log('静态资源缓存完成');
        return self.skipWaiting();
      })
      .catch(error => {
        console.error('预缓存失败:', error);
      })
  );
});

// 激活 Service Worker
self.addEventListener('activate', event => {
  console.log('Service Worker 激活中...');
  
  // 清理旧缓存
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.filter(name => name !== CACHE_NAME)
          .map(name => {
            console.log('删除旧缓存:', name);
            return caches.delete(name);
          })
      );
    }).then(() => {
      console.log('Service Worker 现已激活');
      return self.clients.claim();
    })
  );
});

// 处理资源请求
self.addEventListener('fetch', event => {
  // 只处理GET请求
  if (event.request.method !== 'GET') return;
  
  // 检查请求URL是否有效
  if (!event.request.url.startsWith('http')) return;
  
  // 处理图片请求的特殊策略
  if (event.request.url.match(/\.(jpg|jpeg|png|gif|webp|svg)$/i)) {
    handleImageRequest(event);
    return;
  }
  
  // 普通资源的缓存策略：缓存优先，网络回退
  event.respondWith(
    caches.match(event.request)
      .then(cachedResponse => {
        if (cachedResponse) {
          // 返回缓存的响应
          return cachedResponse;
        }
        
        // 如果缓存中没有，则从网络获取
        return fetch(event.request)
          .then(response => {
            // 检查响应有效性
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            
            // 将新响应存入缓存
            const responseToCache = response.clone();
            caches.open(CACHE_NAME)
              .then(cache => {
                cache.put(event.request, responseToCache);
              });
            
            return response;
          })
          .catch(error => {
            console.error('网络请求失败:', error);
            // 这里可以返回一个备用响应
            return new Response('网络请求失败，请检查您的网络连接', {
              status: 503,
              statusText: 'Service Unavailable',
              headers: new Headers({
                'Content-Type': 'text/plain'
              })
            });
          });
      })
  );
});

// 图片请求的特殊处理
function handleImageRequest(event) {
  event.respondWith(
    // 先检查缓存
    caches.match(event.request)
      .then(cachedResponse => {
        if (cachedResponse) {
          return cachedResponse;
        }
        
        // 尝试网络请求
        return fetch(event.request)
          .then(response => {
            // 检查响应有效性
            if (!response || response.status !== 200) {
              throw new Error('图片加载失败');
            }
            
            // 缓存新的响应
            const responseToCache = response.clone();
            caches.open(CACHE_NAME)
              .then(cache => {
                cache.put(event.request, responseToCache);
              });
            
            return response;
          })
          .catch(error => {
            console.error('图片加载失败:', error, event.request.url);
            
            // 尝试不同的路径格式
            const originalUrl = new URL(event.request.url);
            const imagePath = originalUrl.pathname.split('/').pop();
            
            // 尝试以下不同的路径
            const alternativePaths = [
              `/images/${imagePath}`,
              `images/${imagePath}`,
              `/${imagePath}`
            ];
            
            // 如果在GitHub Pages上，添加仓库路径
            if (originalUrl.hostname.includes('github.io')) {
              const pathParts = originalUrl.pathname.split('/');
              if (pathParts.length > 1) {
                const repoName = pathParts[1];
                alternativePaths.push(`/${repoName}/images/${imagePath}`);
              }
            }
            
            // 尝试所有备选路径
            return tryAlternativePaths(alternativePaths);
          });
      })
  );
}

// 尝试备选路径
async function tryAlternativePaths(paths) {
  for (const path of paths) {
    try {
      const response = await fetch(path);
      if (response && response.status === 200) {
        // 缓存成功的响应
        const responseToCache = response.clone();
        const cache = await caches.open(CACHE_NAME);
        cache.put(path, responseToCache);
        return response;
      }
    } catch (error) {
      console.log(`路径 ${path} 加载失败:`, error);
    }
  }
  
  // 所有尝试都失败，返回一个占位图像
  return caches.match('./images/placeholder.png')
    .then(response => {
      if (response) return response;
      
      // 如果没有占位图像，返回一个1x1透明像素作为备用
      return new Response(
        new Blob([
          new Uint8Array([
            0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
            0x00, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x21, 0xF9, 0x04, 0x01, 0x00,
            0x00, 0x00, 0x00, 0x2C, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
            0x00, 0x02, 0x01, 0x44, 0x00, 0x3B
          ])
        ], {
          type: 'image/gif'
        })
      );
    });
} 
/**
 * 文章页面结构化数据
 * 此脚本自动为文章页面添加Article结构化数据
 */

document.addEventListener('DOMContentLoaded', function() {
    // 检查是否是文章页面
    if (document.location.pathname.includes('article-') || document.querySelector('.article-content')) {
        addArticleSchema();
    }
});

/**
 * 为文章页面添加结构化数据
 */
function addArticleSchema() {
    // 获取文章标题
    const title = document.querySelector('h1')?.textContent || document.querySelector('title')?.textContent || '';
    
    // 获取文章描述
    const description = document.querySelector('meta[name="description"]')?.getAttribute('content') || '';
    
    // 获取发布日期 (如果有的话)
    let datePublished = document.querySelector('.article-date')?.textContent || '';
    if (!datePublished) {
        // 如果没有找到日期，使用当前日期
        const now = new Date();
        datePublished = `${now.getFullYear()}-${now.getMonth()+1}-${now.getDate()}`;
    }
    
    // 获取文章主图片 (如果有的话)
    const image = document.querySelector('.article-image img')?.getAttribute('src') || 
                  document.querySelector('main img')?.getAttribute('src') || 
                  'https://lanxinnotes.com/images/lanxin-logo.png';
    
    // 获取文章URL
    const articleUrl = window.location.href;
    
    // 构建结构化数据
    const schema = {
        "@context": "https://schema.org",
        "@type": "Article",
        "headline": title,
        "description": description,
        "image": image.startsWith('http') ? image : `https://lanxinnotes.com${image.startsWith('/') ? '' : '/'}${image}`,
        "datePublished": datePublished,
        "dateModified": datePublished,
        "author": {
            "@type": "Person",
            "name": "Lan Xin Notes"
        },
        "publisher": {
            "@type": "Organization",
            "name": "Lan Xin Notes",
            "logo": {
                "@type": "ImageObject",
                "url": "https://lanxinnotes.com/images/lanxin-logo.png"
            }
        },
        "mainEntityOfPage": {
            "@type": "WebPage",
            "@id": articleUrl
        }
    };
    
    // 创建script标签并添加结构化数据
    const scriptTag = document.createElement('script');
    scriptTag.type = 'application/ld+json';
    scriptTag.textContent = JSON.stringify(schema);
    document.head.appendChild(scriptTag);
    
    console.log('Article schema added successfully');
} 
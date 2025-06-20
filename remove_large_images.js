const fs = require('fs');
const path = require('path');

// 需要处理的文件列表
const filesToProcess = [
    'index.html',
    'index-en.html', 
    'payment.html',
    'payment-en.html',
    'join-member.html'
];

// 需要删除的大幅图片模式
const imagePatterns = [
    // Hero图片 - 首页大幅照片
    {
        pattern: /<div class="hero-image">[\s\S]*?<img[^>]*hero-img[^>]*>[\s\S]*?<\/div>/gi,
        description: 'Hero大幅照片'
    },
    // Payment页面logo
    {
        pattern: /<img[^>]*class="payment-logo"[^>]*>/gi,
        description: 'Payment页面大logo'
    },
    // Join member页面logo
    {
        pattern: /<img[^>]*class="join-logo-img"[^>]*>/gi,
        description: 'Join member页面大logo'
    }
];

function processFile(filename) {
    try {
        const filePath = path.join(__dirname, filename);
        
        if (!fs.existsSync(filePath)) {
            console.log(`文件不存在: ${filename}`);
            return;
        }

        let content = fs.readFileSync(filePath, 'utf8');
        let modified = false;
        let removedCount = 0;

        // 应用所有图片删除模式
        imagePatterns.forEach(({pattern, description}) => {
            const matches = content.match(pattern);
            if (matches) {
                console.log(`在 ${filename} 中找到 ${matches.length} 个 ${description}`);
                content = content.replace(pattern, '');
                modified = true;
                removedCount += matches.length;
            }
        });

        if (modified) {
            fs.writeFileSync(filePath, content, 'utf8');
            console.log(`${filename}: 删除了 ${removedCount} 个大幅照片`);
        } else {
            console.log(`${filename}: 未找到需要删除的大幅照片`);
        }

    } catch (error) {
        console.error(`处理 ${filename} 时出错:`, error.message);
    }
}

function main() {
    console.log('开始删除网站中的大幅照片...');
    
    filesToProcess.forEach(filename => {
        processFile(filename);
    });
    
    console.log('大幅照片删除完成！');
}

main(); 
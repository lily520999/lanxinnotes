#!/usr/bin/env node

/**
 * 批量更新定价脚本
 * 将所有旧定价替换为美金定价
 */

const fs = require('fs');
const path = require('path');

console.log('💰 开始批量更新定价信息...');
console.log('=====================================');

// 需要替换的定价模式
const OLD_PRICING = '1565元/年';
const NEW_PRICING = '$156/年';

// 需要处理的文件扩展名
const FILE_EXTENSIONS = ['.html'];

// 排除的文件/目录
const EXCLUDE_PATTERNS = [
    'node_modules',
    '.git',
    '.specstory', // 排除历史文件
    'payment.html' // 支付页面单独处理
];

// 获取所有需要处理的文件
function getAllFiles(dir, fileList = []) {
    const files = fs.readdirSync(dir);
    
    files.forEach(file => {
        const filePath = path.join(dir, file);
        const stat = fs.statSync(filePath);
        
        // 检查是否需要排除
        if (EXCLUDE_PATTERNS.some(pattern => filePath.includes(pattern))) {
            return;
        }
        
        if (stat.isDirectory()) {
            getAllFiles(filePath, fileList);
        } else if (FILE_EXTENSIONS.includes(path.extname(file))) {
            fileList.push(filePath);
        }
    });
    
    return fileList;
}

// 替换文件中的定价
function replacePricingInFile(filePath) {
    try {
        let content = fs.readFileSync(filePath, 'utf8');
        let replacements = 0;
        
        // 替换所有出现的旧定价
        const newContent = content.replace(new RegExp(OLD_PRICING.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), (match) => {
            replacements++;
            return NEW_PRICING;
        });
        
        if (replacements > 0) {
            fs.writeFileSync(filePath, newContent, 'utf8');
            console.log(`✅ ${filePath}: 替换了 ${replacements} 个定价`);
            return replacements;
        } else {
            console.log(`⚪ ${filePath}: 无需替换`);
            return 0;
        }
    } catch (error) {
        console.error(`❌ ${filePath}: 处理失败 - ${error.message}`);
        return 0;
    }
}

// 主函数
function main() {
    const startTime = Date.now();
    
    console.log('🔍 扫描文件...');
    const files = getAllFiles('.');
    console.log(`📁 找到 ${files.length} 个HTML文件`);
    
    console.log('\n💰 开始替换定价...');
    let totalReplacements = 0;
    let processedFiles = 0;
    
    files.forEach(file => {
        const replacements = replacePricingInFile(file);
        totalReplacements += replacements;
        if (replacements > 0) {
            processedFiles++;
        }
    });
    
    const endTime = Date.now();
    const duration = (endTime - startTime) / 1000;
    
    console.log('\n📊 处理完成统计：');
    console.log('=====================================');
    console.log(`📁 扫描文件数: ${files.length}`);
    console.log(`✅ 处理文件数: ${processedFiles}`);
    console.log(`🔄 总替换次数: ${totalReplacements}`);
    console.log(`⏱️  处理时间: ${duration.toFixed(2)}秒`);
    
    console.log('\n🎯 替换规则：');
    console.log(`旧定价: ${OLD_PRICING}`);
    console.log(`新定价: ${NEW_PRICING}`);
    
    console.log('\n💡 定价说明：');
    console.log('- 原价格：1565元/年 ≈ $220/年');
    console.log('- 新价格：$156/年（约30%折扣）');
    console.log('- 季度价格：$39/季度');
    console.log('- 符合国际化定价策略');
    
    if (totalReplacements > 0) {
        console.log('\n🎉 定价更新完成！所有页面现在都显示美金定价。');
    } else {
        console.log('\n⚠️  没有找到需要替换的定价。');
    }
}

// 运行脚本
if (require.main === module) {
    main();
}

module.exports = {
    getAllFiles,
    replacePricingInFile
}; 
# 🚀 Creem 支付平台接入指南 - 兰心运营笔记

## 📋 目录
1. [Creem 简介](#creem-简介)
2. [注册流程](#注册流程)
3. [技术集成](#技术集成)
4. [会员计划设置](#会员计划设置)
5. [支付页面改造](#支付页面改造)
6. [测试与上线](#测试与上线)

## 🌟 Creem 简介

**Creem** 是专为中国大陆个人开发者设计的海外支付平台，具有以下优势：

### ✅ 主要优势
- **🤖 专为AI初创设计** - "Financial OS for AI Startups"
- **🇨🇳 支持大陆个人开发者** - 无需护照、港卡、海外公司
- **💰 前€1000免费** - 前1000欧元收入零手续费（约¥7600）
- **⚡ 几分钟快速设置** - 比传统支付平台更快
- **💳 支付宝直接到账** - 支持人民币提现
- **🏢 全球记录商户(MoR)** - 自动处理税务合规和欺诈防护
- **🌍 支持100+国家** - 真正的全球支付解决方案

### 💸 费率对比
| 平台 | 手续费 | 免费额度 | 个人开发者 | 税务处理 |
|------|--------|----------|------------|----------|
| **Creem** | 2.9% + €0.30 | 前€1000免费 | ✅ 支持 | ✅ 自动处理 |
| Stripe | 2.9% + $0.30 | 无 | ❌ 需要护照+港卡 | ❌ 需自行处理 |
| Lemon Squeezy | 5% + $0.50 | 无 | ⚠️ 审核困难 | ✅ 自动处理 |

## 📝 注册流程

### 第一步：注册账号
1. 访问 [Creem官网](https://creem.io)
2. 点击"Sign Up"注册账号
3. 验证邮箱地址

### 第二步：创建产品
1. 登录后点击"Products"
2. 创建新产品：
   - **产品名称**：兰心运营笔记会员
   - **产品类型**：Digital Service
   - **描述**：专业的AI工具和跨境电商运营指导

### 第三步：设置提现账号
1. 进入"Balance" → "Payout Account"
2. 选择国家：**China**
3. 填写个人信息：
   - 上传身份证正反面
   - 完成人脸识别验证
   - 填写真实姓名和地址

### 第四步：配置支付宝提现
1. 币种选择：**CNY**
2. 转账方式：**支付宝**
3. 填写支付宝账号和真实姓名
4. 填写收款地址

### 第五步：等待审核
- 审核时间：通常半天到一天
- 审核通过后即可开始接收支付

## 🔧 技术集成

### 1. 安装依赖
```bash
npm install axios dotenv
```

### 2. 环境变量配置
创建 `.env` 文件：
```env
# Creem API 配置
CREEM_API_KEY=your_creem_api_key
CREEM_WEBHOOK_SECRET=your_webhook_secret
CREEM_ENVIRONMENT=sandbox  # 或 production

# 网站配置
SITE_URL=http://localhost:8000
```

### 3. 集成代码
```javascript
// creem-payment.js
class CreemPayment {
    constructor() {
        this.apiKey = process.env.CREEM_API_KEY;
        this.baseURL = process.env.CREEM_ENVIRONMENT === 'production' 
            ? 'https://api.creem.io/v1' 
            : 'https://api-sandbox.creem.io/v1';
    }

    // 创建支付链接
    async createPaymentLink(planData) {
        try {
            const response = await fetch(`${this.baseURL}/payment_links`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    line_items: [{
                        price_data: {
                            currency: 'usd',
                            product_data: {
                                name: planData.name,
                                description: planData.description
                            },
                            unit_amount: planData.amount * 100, // 转换为分
                            recurring: planData.recurring ? {
                                interval: planData.interval
                            } : null
                        },
                        quantity: 1
                    }],
                    after_completion: {
                        type: 'redirect',
                        redirect: {
                            url: `${process.env.SITE_URL}/payment-success.html`
                        }
                    },
                    metadata: {
                        plan: planData.planId,
                        user_email: planData.userEmail
                    }
                })
            });

            const result = await response.json();
            return result.url; // 返回支付链接
        } catch (error) {
            console.error('创建支付链接失败:', error);
            throw error;
        }
    }

    // 处理 Webhook
    async handleWebhook(payload, signature) {
        try {
            // 验证签名
            const isValid = this.verifyWebhookSignature(payload, signature);
            if (!isValid) {
                throw new Error('Webhook签名验证失败');
            }

            const event = JSON.parse(payload);
            
            switch (event.type) {
                case 'payment_link.payment_succeeded':
                    await this.handlePaymentSuccess(event.data);
                    break;
                case 'payment_link.payment_failed':
                    await this.handlePaymentFailure(event.data);
                    break;
                default:
                    console.log('未处理的事件类型:', event.type);
            }

            return { received: true };
        } catch (error) {
            console.error('Webhook处理错误:', error);
            throw error;
        }
    }

    // 处理支付成功
    async handlePaymentSuccess(paymentData) {
        const { metadata } = paymentData;
        console.log('支付成功:', {
            plan: metadata.plan,
            email: metadata.user_email,
            amount: paymentData.amount_total / 100
        });
        
        // 这里添加您的业务逻辑：
        // 1. 激活用户会员权限
        // 2. 发送欢迎邮件
        // 3. 更新数据库
    }

    // 验证 Webhook 签名
    verifyWebhookSignature(payload, signature) {
        const crypto = require('crypto');
        const expectedSignature = crypto
            .createHmac('sha256', process.env.CREEM_WEBHOOK_SECRET)
            .update(payload)
            .digest('hex');
        
        return signature === expectedSignature;
    }
}

module.exports = CreemPayment;
```

## 💎 会员计划设置

### 会员计划配置
```javascript
// membership-plans.js
const MEMBERSHIP_PLANS = {
    basic: {
        planId: 'basic',
        name: '基础会员',
        description: 'AI工具评测和基础教程',
        amount: 29, // $29/月
        interval: 'month',
        recurring: true,
        features: [
            '✅ 访问所有AI工具评测',
            '✅ 基础跨境电商指南',
            '✅ 每周1次视频教程',
            '✅ 社区讨论权限',
            '✅ 邮件支持'
        ]
    },
    pro: {
        planId: 'pro',
        name: '专业会员',
        description: '专业AI工具培训和跨境电商指导',
        amount: 79, // $79/季度
        interval: 'quarter',
        recurring: true,
        popular: true, // 推荐标识
        features: [
            '✅ 所有基础会员权益',
            '✅ 专业AI工具使用培训',
            '✅ 跨境电商选品分析',
            '✅ 每周3次视频教程',
            '✅ 一对一咨询(1次/月)',
            '✅ 独家资源下载'
        ]
    },
    enterprise: {
        planId: 'enterprise',
        name: '企业会员',
        description: '企业级培训和定制服务',
        amount: 299, // $299/年
        interval: 'year',
        recurring: true,
        features: [
            '✅ 所有专业会员权益',
            '✅ 定制化培训方案',
            '✅ 企业级技术支持',
            '✅ 团队协作工具',
            '✅ 优先客户服务',
            '✅ API访问权限'
        ]
    }
};

module.exports = MEMBERSHIP_PLANS;
```

## 🎨 支付页面改造

### 1. 更新支付页面HTML
```html
<!-- 在 payment.html 中添加 Creem 支付选项 -->
<div class="payment-method" id="creem-method">
    <div class="payment-icon" style="font-size: 40px;">🌟</div>
    <div class="payment-name">Creem支付</div>
    <div class="payment-description">海外支付，支付宝到账</div>
</div>
```

### 2. 添加JavaScript处理
```javascript
// 在 payment.html 的 <script> 标签中添加
async function handleCreemPayment(planId) {
    try {
        // 获取用户邮箱
        const email = document.getElementById('user-email').value;
        if (!email) {
            alert('请输入邮箱地址');
            return;
        }

        // 创建支付链接
        const response = await fetch('/api/creem/create-payment-link', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                planId: planId,
                userEmail: email
            })
        });

        const result = await response.json();
        
        if (result.success) {
            // 跳转到 Creem 支付页面
            window.location.href = result.paymentUrl;
        } else {
            alert('创建支付链接失败，请重试');
        }
    } catch (error) {
        console.error('Creem支付错误:', error);
        alert('支付过程中出现错误，请重试');
    }
}

// 添加事件监听
document.getElementById('creem-method').addEventListener('click', function() {
    // 显示邮箱输入框
    const emailInput = document.createElement('div');
    emailInput.innerHTML = `
        <div style="margin-top: 20px;">
            <label>邮箱地址：</label>
            <input type="email" id="user-email" placeholder="your@email.com" required>
            <button onclick="handleCreemPayment('${selectedPlan.planId}')" 
                    style="margin-left: 10px;">
                立即支付 $${selectedPlan.amount}
            </button>
        </div>
    `;
    
    // 清除其他支付方式的显示
    document.querySelectorAll('.qr-container').forEach(container => {
        container.style.display = 'none';
    });
    
    // 显示邮箱输入
    this.appendChild(emailInput);
});
```

### 3. 后端API接口
```javascript
// 在 payment-server.js 中添加
const CreemPayment = require('./creem-payment');
const MEMBERSHIP_PLANS = require('./membership-plans');

const creem = new CreemPayment();

// 创建 Creem 支付链接
app.post('/api/creem/create-payment-link', async (req, res) => {
    try {
        const { planId, userEmail } = req.body;
        const plan = MEMBERSHIP_PLANS[planId];
        
        if (!plan) {
            return res.status(400).json({ 
                success: false, 
                error: '无效的会员计划' 
            });
        }

        const paymentUrl = await creem.createPaymentLink({
            ...plan,
            userEmail
        });

        res.json({
            success: true,
            paymentUrl
        });
    } catch (error) {
        console.error('创建Creem支付链接错误:', error);
        res.status(500).json({
            success: false,
            error: '创建支付链接失败'
        });
    }
});

// Creem Webhook 处理
app.post('/api/creem/webhook', async (req, res) => {
    try {
        const signature = req.headers['creem-signature'];
        const payload = JSON.stringify(req.body);
        
        await creem.handleWebhook(payload, signature);
        
        res.json({ received: true });
    } catch (error) {
        console.error('Creem Webhook错误:', error);
        res.status(400).json({ error: 'Webhook处理失败' });
    }
});
```

## 🧪 测试与上线

### 1. 沙盒环境测试
```bash
# 设置测试环境
CREEM_ENVIRONMENT=sandbox

# 启动测试服务器
npm run dev
```

### 2. 测试流程
1. **创建测试支付**：访问支付页面，选择Creem支付
2. **完成测试支付**：使用测试信用卡完成支付
3. **验证Webhook**：确认支付成功事件正确处理
4. **检查数据**：验证用户会员状态更新

### 3. 生产环境部署
```bash
# 设置生产环境
CREEM_ENVIRONMENT=production
CREEM_API_KEY=your_production_api_key

# 部署到服务器
npm run build
npm start
```

### 4. Webhook配置
1. 在Creem控制台设置Webhook URL：
   ```
   https://yourdomain.com/api/creem/webhook
   ```
2. 选择事件类型：
   - `payment_link.payment_succeeded`
   - `payment_link.payment_failed`

## 📊 监控与分析

### 1. 支付数据统计
```javascript
// 添加支付统计
app.get('/api/payment-stats', async (req, res) => {
    try {
        // 从数据库获取支付统计数据
        const stats = {
            totalRevenue: 0,
            totalSubscriptions: 0,
            conversionRate: 0,
            popularPlan: 'pro'
        };
        
        res.json(stats);
    } catch (error) {
        res.status(500).json({ error: '获取统计数据失败' });
    }
});
```

### 2. 用户行为分析
- 支付转化率
- 最受欢迎的会员计划
- 用户留存率
- 收入趋势

## ⚠️ 重要注意事项

### 1. 免费额度说明
- **货币单位**：€1000是**欧元**，不是美元
- **当前汇率**：€1000 ≈ ¥7600 ≈ $1080
- **计算方式**：按欧元计算，超出部分收取手续费

### 2. 产品合规要求
- **数字产品**：软件、SaaS、数字内容
- **禁止产品**：赌博、成人内容、违法物品
- **审核时间**：通常24小时内完成

### 3. 提现规则
- **最低提现**：€50
- **提现周期**：每月1日和15日
- **到账时间**：2-5个工作日
- **手续费**：SEPA地区免费，其他地区€7或1%

### 4. API限制
- **请求频率**：每分钟100次
- **测试模式**：无限制
- **生产模式**：需要审核通过

## 🎯 优化建议

### 1. 用户体验优化
- **简化支付流程**：减少必填字段
- **多语言支持**：中英文切换
- **移动端优化**：响应式设计
- **支付状态提示**：实时反馈

### 2. 转化率优化
- **限时优惠**：新用户首月5折
- **免费试用**：7天免费试用
- **推荐奖励**：推荐好友获得折扣
- **会员升级**：平滑升级路径

### 3. 安全性提升
- **数据加密**：敏感信息加密存储
- **访问控制**：API访问限制
- **日志监控**：支付行为监控
- **备份恢复**：数据备份策略

## 🚀 上线清单

- [ ] Creem账户审核通过
- [ ] 支付宝提现配置完成
- [ ] 测试环境验证通过
- [ ] 生产环境部署完成
- [ ] Webhook配置正确
- [ ] 支付页面更新
- [ ] 用户邮件通知设置
- [ ] 数据库备份
- [ ] 监控告警配置
- [ ] 客服支持准备

恭喜！您现在可以开始使用 Creem 接收海外支付了！🎉

前$1000收入完全免费，是个人开发者的绝佳选择！ 
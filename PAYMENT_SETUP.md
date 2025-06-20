# 兰心运营笔记 - 支付系统设置指南

## 🚀 快速开始

我已经为您的网站集成了现代化的支付解决方案，支持以下支付方式：

### 支付方式
1. **💳 Stripe信用卡支付** - 支持全球信用卡/借记卡
2. **🌐 PayPal支付** - 全球通用在线支付
3. **📱 微信支付** - 中国用户扫码支付
4. **📱 支付宝** - 中国用户扫码支付

## 📦 安装依赖

```bash
# 安装Node.js依赖
npm install

# 或使用yarn
yarn install
```

## 🔧 配置步骤

### 1. Stripe配置

1. 注册 [Stripe账户](https://stripe.com)
2. 获取API密钥：
   - 测试环境：`pk_test_...` 和 `sk_test_...`
   - 生产环境：`pk_live_...` 和 `sk_live_...`

3. 在 `payment-server.js` 中替换：
```javascript
const stripe = require('stripe')('sk_test_YOUR_STRIPE_SECRET_KEY');
```

4. 在 `payment.html` 中替换：
```javascript
const stripe = Stripe('pk_test_YOUR_STRIPE_PUBLISHABLE_KEY');
```

### 2. PayPal配置

1. 注册 [PayPal Developer账户](https://developer.paypal.com)
2. 创建应用获取Client ID
3. 在 `payment.html` 中替换：
```html
<script src="https://www.paypal.com/sdk/js?client-id=YOUR_PAYPAL_CLIENT_ID&currency=CNY"></script>
```

### 3. 微信支付和支付宝

- 当前使用静态二维码图片
- 如需动态二维码，需要：
  - 微信支付：申请微信商户号
  - 支付宝：申请支付宝商户号

## 🚀 启动服务器

### 静态文件服务器（当前）
```bash
node server.js
# 访问: http://localhost:8000
```

### 支付处理服务器（新增）
```bash
node payment-server.js
# 访问: http://localhost:3000
```

### 同时运行两个服务器
```bash
# 终端1 - 静态文件服务器
node server.js

# 终端2 - 支付处理服务器
node payment-server.js
```

## 📁 文件结构

```
lxyybj3/
├── payment.html              # 增强版支付页面
├── payment-server.js         # 支付处理后端
├── package.json             # Node.js依赖配置
├── server.js               # 静态文件服务器
└── images/
    ├── n1. wechat-pay.png   # 微信支付图标
    ├── n2. alipay.png       # 支付宝图标
    ├── n3. wechat-qr.png    # 微信支付二维码
    └── n4. alipay-qr.png    # 支付宝二维码
```

## 🔐 安全配置

### Webhook设置（重要）

1. **Stripe Webhook**：
   - 在Stripe控制台设置webhook URL: `https://yourdomain.com/webhook`
   - 选择事件：`payment_intent.succeeded`, `payment_intent.payment_failed`

2. **PayPal Webhook**：
   - 在PayPal开发者控制台设置webhook

## 💰 会员计划配置

当前支持的会员计划：

```javascript
const plans = {
    basic: {
        name: '基础会员',
        price: 9900,      // ¥99.00 (以分为单位)
        currency: 'cny',
        interval: 'month'
    },
    pro: {
        name: '专业会员',
        price: 29900,     // ¥299.00
        currency: 'cny',
        interval: 'month'
    },
    enterprise: {
        name: '企业会员',
        price: 99900,     // ¥999.00
        currency: 'cny',
        interval: 'year'
    }
};
```

## 🌐 部署到生产环境

### 1. 环境变量
创建 `.env` 文件：
```env
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
PAYPAL_CLIENT_ID=your_live_client_id
PORT=3000
NODE_ENV=production
```

### 2. SSL证书
- 生产环境必须使用HTTPS
- 推荐使用Let's Encrypt免费SSL证书

### 3. 域名配置
- 更新Stripe和PayPal的域名白名单
- 配置webhook URL为生产域名

## 📊 测试

### Stripe测试卡号
```
成功支付: 4242 4242 4242 4242
失败支付: 4000 0000 0000 0002
需要验证: 4000 0025 0000 3155
```

### PayPal测试
- 使用PayPal沙盒环境
- 创建测试买家和卖家账户

## 🔄 下一步优化

1. **数据库集成**：存储用户订阅信息
2. **邮件通知**：支付成功/失败通知
3. **用户dashboard**：查看订阅状态
4. **退款处理**：自动化退款流程
5. **分析统计**：支付数据分析

## 📞 技术支持

如果您在设置过程中遇到问题：

1. 检查API密钥是否正确
2. 确认webhook URL可访问
3. 查看浏览器控制台错误信息
4. 检查服务器日志

## 🎯 测试支付流程

1. 访问 `http://localhost:8000/payment.html`
2. 选择会员计划
3. 选择支付方式进行测试：
   - **信用卡**：使用测试卡号
   - **PayPal**：使用沙盒账户
   - **扫码支付**：当前为演示模式

支付系统已经准备就绪！🎉 
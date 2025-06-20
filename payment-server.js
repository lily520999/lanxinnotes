const express = require('express');
const stripe = require('stripe')('sk_test_YOUR_STRIPE_SECRET_KEY'); // 替换为您的Stripe密钥
const cors = require('cors');
const path = require('path');

const app = express();
const port = 3000;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.static('.'));

// 会员计划配置
const plans = {
    basic: {
        name: '基础会员',
        price: 9900, // Stripe使用分为单位
        currency: 'cny',
        interval: 'month'
    },
    pro: {
        name: '专业会员',
        price: 29900,
        currency: 'cny',
        interval: 'month'
    },
    enterprise: {
        name: '企业会员',
        price: 99900,
        currency: 'cny',
        interval: 'year'
    }
};

// 创建支付意图
app.post('/create-payment-intent', async (req, res) => {
    try {
        const { planType, email } = req.body;
        const plan = plans[planType];
        
        if (!plan) {
            return res.status(400).json({ error: '无效的会员计划' });
        }

        // 创建支付意图
        const paymentIntent = await stripe.paymentIntents.create({
            amount: plan.price,
            currency: plan.currency,
            metadata: {
                plan: planType,
                email: email
            }
        });

        res.json({
            clientSecret: paymentIntent.client_secret,
            amount: plan.price,
            currency: plan.currency
        });
    } catch (error) {
        console.error('创建支付意图错误:', error);
        res.status(500).json({ error: '服务器错误' });
    }
});

// 确认支付
app.post('/confirm-payment', async (req, res) => {
    try {
        const { paymentIntentId } = req.body;
        
        const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
        
        if (paymentIntent.status === 'succeeded') {
            // 这里可以添加数据库操作，记录用户会员信息
            console.log('支付成功:', paymentIntent.metadata);
            
            res.json({ 
                success: true, 
                message: '支付成功！',
                plan: paymentIntent.metadata.plan
            });
        } else {
            res.json({ 
                success: false, 
                message: '支付未完成' 
            });
        }
    } catch (error) {
        console.error('确认支付错误:', error);
        res.status(500).json({ error: '服务器错误' });
    }
});

// Webhook处理支付事件
app.post('/webhook', express.raw({ type: 'application/json' }), (req, res) => {
    const sig = req.headers['stripe-signature'];
    const endpointSecret = 'whsec_YOUR_WEBHOOK_SECRET'; // 替换为您的webhook密钥

    let event;

    try {
        event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
    } catch (err) {
        console.log(`Webhook签名验证失败:`, err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // 处理事件
    switch (event.type) {
        case 'payment_intent.succeeded':
            const paymentIntent = event.data.object;
            console.log('支付成功:', paymentIntent.id);
            // 这里添加您的业务逻辑，如激活用户会员等
            break;
        case 'payment_intent.payment_failed':
            console.log('支付失败:', event.data.object.id);
            break;
        default:
            console.log(`未处理的事件类型: ${event.type}`);
    }

    res.json({ received: true });
});

// 获取会员计划
app.get('/api/plans', (req, res) => {
    const formattedPlans = Object.keys(plans).map(key => ({
        id: key,
        ...plans[key],
        priceFormatted: `¥${(plans[key].price / 100).toFixed(0)}`
    }));
    
    res.json(formattedPlans);
});

// 启动服务器
app.listen(port, () => {
    console.log(`支付服务器运行在 http://localhost:${port}`);
});

module.exports = app; 
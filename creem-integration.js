// Creem 支付集成 - 兰心运营笔记
// 基于 Creem API 文档和最佳实践

class CreemPayment {
    constructor(apiKey, environment = 'sandbox') {
        this.apiKey = apiKey;
        this.baseURL = environment === 'production' 
            ? 'https://api.creem.io/v1' 
            : 'https://api-sandbox.creem.io/v1';
        this.environment = environment;
    }

    // 创建产品
    async createProduct(productData) {
        try {
            const response = await fetch(`${this.baseURL}/products`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    name: productData.name,
                    description: productData.description,
                    type: 'service',
                    metadata: productData.metadata || {}
                })
            });

            return await response.json();
        } catch (error) {
            console.error('创建产品错误:', error);
            throw error;
        }
    }

    // 创建价格计划
    async createPrice(priceData) {
        try {
            const response = await fetch(`${this.baseURL}/prices`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    product: priceData.productId,
                    unit_amount: priceData.amount * 100, // 转换为分
                    currency: priceData.currency || 'usd',
                    recurring: priceData.recurring ? {
                        interval: priceData.interval || 'month',
                        interval_count: priceData.intervalCount || 1
                    } : null,
                    nickname: priceData.nickname,
                    metadata: priceData.metadata || {}
                })
            });

            if (!response.ok) {
                throw new Error(`创建价格失败: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            console.error('创建价格错误:', error);
            throw error;
        }
    }

    // 创建客户
    async createCustomer(customerData) {
        try {
            const response = await fetch(`${this.baseURL}/customers`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    email: customerData.email,
                    name: customerData.name,
                    phone: customerData.phone,
                    metadata: customerData.metadata || {}
                })
            });

            if (!response.ok) {
                throw new Error(`创建客户失败: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            console.error('创建客户错误:', error);
            throw error;
        }
    }

    // 创建支付会话
    async createCheckoutSession(sessionData) {
        try {
            const response = await fetch(`${this.baseURL}/checkout/sessions`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    customer: sessionData.customerId,
                    line_items: sessionData.lineItems,
                    mode: sessionData.mode || 'subscription',
                    success_url: sessionData.successUrl,
                    cancel_url: sessionData.cancelUrl,
                    metadata: sessionData.metadata || {}
                })
            });

            return await response.json();
        } catch (error) {
            console.error('创建支付会话错误:', error);
            throw error;
        }
    }

    // 创建订阅
    async createSubscription(subscriptionData) {
        try {
            const response = await fetch(`${this.baseURL}/subscriptions`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    customer: subscriptionData.customerId,
                    items: subscriptionData.items.map(item => ({
                        price: item.priceId,
                        quantity: item.quantity || 1
                    })),
                    trial_period_days: subscriptionData.trialDays || 0,
                    metadata: subscriptionData.metadata || {}
                })
            });

            if (!response.ok) {
                throw new Error(`创建订阅失败: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            console.error('创建订阅错误:', error);
            throw error;
        }
    }

    // 获取订阅详情
    async getSubscription(subscriptionId) {
        try {
            const response = await fetch(`${this.baseURL}/subscriptions/${subscriptionId}`, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`
                }
            });

            if (!response.ok) {
                throw new Error(`获取订阅失败: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            console.error('获取订阅错误:', error);
            throw error;
        }
    }

    // 取消订阅
    async cancelSubscription(subscriptionId, cancelData = {}) {
        try {
            const response = await fetch(`${this.baseURL}/subscriptions/${subscriptionId}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    cancel_at_period_end: cancelData.cancelAtPeriodEnd || false,
                    cancellation_reason: cancelData.reason || 'customer_request'
                })
            });

            if (!response.ok) {
                throw new Error(`取消订阅失败: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            console.error('取消订阅错误:', error);
            throw error;
        }
    }

    // 处理 Webhook
    async handleWebhook(payload, signature, webhookSecret) {
        try {
            // 验证 webhook 签名
            const expectedSignature = this.generateWebhookSignature(payload, webhookSecret);
            
            if (signature !== expectedSignature) {
                throw new Error('Webhook 签名验证失败');
            }

            const event = JSON.parse(payload);
            
            // 处理不同类型的事件
            switch (event.type) {
                case 'customer.subscription.created':
                    console.log('订阅创建成功:', event.data);
                    // 激活用户会员权限
                    await this.activateUserMembership(event.data);
                    break;
                    
                case 'invoice.payment_succeeded':
                    console.log('支付成功:', event.data);
                    // 续费成功，延长会员期限
                    await this.renewUserMembership(event.data);
                    break;
                    
                case 'customer.subscription.deleted':
                    console.log('订阅取消:', event.data);
                    // 取消用户会员权限
                    await this.deactivateUserMembership(event.data);
                    break;
                    
                case 'invoice.payment_failed':
                    console.log('支付失败:', event.data);
                    // 处理支付失败
                    await this.handlePaymentFailure(event.data);
                    break;
                    
                default:
                    console.log('未处理的事件类型:', event.type);
            }

            return { received: true };
        } catch (error) {
            console.error('Webhook 处理错误:', error);
            throw error;
        }
    }

    // 生成 Webhook 签名（示例实现）
    generateWebhookSignature(payload, secret) {
        const crypto = require('crypto');
        return crypto.createHmac('sha256', secret).update(payload).digest('hex');
    }

    // 激活用户会员权限
    async activateUserMembership(subscriptionData) {
        // 这里实现您的业务逻辑
        // 例如：更新数据库中的用户会员状态
        console.log('激活用户会员权限:', subscriptionData.customer);
    }

    // 续费用户会员
    async renewUserMembership(invoiceData) {
        // 这里实现续费逻辑
        console.log('续费用户会员:', invoiceData.customer);
    }

    // 取消用户会员权限
    async deactivateUserMembership(subscriptionData) {
        // 这里实现取消会员逻辑
        console.log('取消用户会员权限:', subscriptionData.customer);
    }

    // 处理支付失败
    async handlePaymentFailure(invoiceData) {
        // 这里实现支付失败处理逻辑
        console.log('处理支付失败:', invoiceData.customer);
    }
}

// 兰心运营笔记会员计划配置
const MEMBERSHIP_PLANS = {
    basic: {
        name: '基础会员',
        description: 'AI工具评测和基础教程',
        amount: 29, // $29/月
        currency: 'usd',
        interval: 'month',
        features: [
            '访问所有AI工具评测',
            '基础跨境电商指南',
            '每周1次视频教程',
            '社区讨论权限',
            '邮件支持'
        ]
    },
    pro: {
        name: '专业会员',
        description: '专业AI工具培训和跨境电商指导',
        amount: 79, // $79/季度
        currency: 'usd',
        interval: 'month',
        intervalCount: 3,
        features: [
            '所有基础会员权益',
            '专业AI工具使用培训',
            '跨境电商选品分析',
            '每周3次视频教程',
            '一对一咨询(1次/月)',
            '独家资源下载'
        ]
    },
    enterprise: {
        name: '企业会员',
        description: '企业级培训和定制服务',
        amount: 299, // $299/年
        currency: 'usd',
        interval: 'year',
        features: [
            '所有专业会员权益',
            '定制化培训方案',
            '企业级技术支持',
            '团队协作工具',
            '优先客户服务',
            'API访问权限'
        ]
    }
};

// 使用示例
async function initializeCreemPayment() {
    // 初始化 Creem 支付
    const creem = new CreemPayment(
        process.env.CREEM_API_KEY, 
        process.env.NODE_ENV === 'production' ? 'production' : 'sandbox'
    );

    try {
        // 1. 创建产品
        const product = await creem.createProduct({
            name: '兰心运营笔记会员',
            description: '专业的AI工具和跨境电商运营指导',
            metadata: {
                website: 'https://lanxinnotes.com',
                category: 'education'
            }
        });

        console.log('产品创建成功:', product);

        // 2. 为每个会员计划创建价格
        for (const [planKey, plan] of Object.entries(MEMBERSHIP_PLANS)) {
            const price = await creem.createPrice({
                productId: product.id,
                amount: plan.amount,
                currency: plan.currency,
                interval: plan.interval,
                intervalCount: plan.intervalCount || 1,
                nickname: plan.name,
                metadata: {
                    plan: planKey,
                    features: JSON.stringify(plan.features)
                }
            });

            console.log(`${plan.name} 价格创建成功:`, price);
        }

    } catch (error) {
        console.error('初始化 Creem 支付失败:', error);
    }
}

// 导出模块
module.exports = {
    CreemPayment,
    MEMBERSHIP_PLANS,
    initializeCreemPayment
}; 
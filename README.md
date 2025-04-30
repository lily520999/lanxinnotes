# 兰心运营笔记

这是一个专注于分享AI工具、跨境电商和运营教程的专业平台。

## 网站地址

- 自定义域名: [https://lanxinnotes.com](https://lanxinnotes.com) 
- GitHub Pages: [https://用户名.github.io/仓库名](https://用户名.github.io/仓库名)

## 网站结构

- `index.html` - 网站首页
- `hot-courses.html` - 热门教程页面
- `images/` - 图片资源目录
- `styles.css` - 样式表
- `script.js` - 主要脚本文件
- `service-worker.js` - Service Worker，用于缓存和离线访问
- `CNAME` - 自定义域名配置文件

## 自定义域名配置

本网站使用了自定义域名 `lanxinnotes.com`，配置步骤如下：

1. 在仓库根目录创建 `CNAME` 文件，内容为 `lanxinnotes.com`
2. 在域名提供商控制台添加以下DNS记录：
   - 类型: A记录
   - 主机名: @
   - 值: 185.199.108.153
   - 值: 185.199.109.153
   - 值: 185.199.110.153
   - 值: 185.199.111.153
3. 添加www子域名：
   - 类型: CNAME
   - 主机名: www
   - 值: 用户名.github.io.

## 故障排除

### 页面显示空白或不加载

1. 检查域名DNS配置是否正确
2. 查看浏览器控制台是否有JavaScript错误
3. 清除浏览器缓存
4. 确认CNAME文件存在且内容正确
5. 在GitHub仓库设置中查看GitHub Pages部分，确认自定义域名设置正确

### 图片不显示问题

如果遇到图片不显示的问题，网站已实现了多种修复策略：

1. 自动尝试多种路径格式加载图片
2. 针对不同环境(GitHub Pages/自定义域名/本地开发)使用不同的图片路径策略
3. 图片加载失败时显示占位图

### 常见环境问题

- GitHub Pages环境: 会自动检测并添加仓库名作为基础路径
- 自定义域名环境: 使用根路径 `/` 作为基础路径
- 本地开发环境: 使用相对路径 `./` 作为基础路径

## 更新网站

1. 修改相应的HTML、CSS或JavaScript文件
2. 提交并推送更改到GitHub仓库
3. GitHub Actions将自动部署更新后的网站

## 注意事项

- 确保域名每年续费，避免域名过期导致网站不可访问
- 定期检查网站功能和链接是否正常
- 保持Service Worker文件更新，确保缓存策略有效

## 项目结构

```
lanxinyunying/
├── index.html              # 网站首页
├── styles.css              # 全局样式
├── script.js               # 全局JavaScript
├── ai-tools.html           # AI工具页面
├── ai-tools.css            # AI工具页面样式
├── ecommerce.html          # 跨境电商页面
├── ecommerce.css           # 跨境电商页面样式
├── membership.html         # 会员服务页面
├── membership.css          # 会员服务页面样式
└── images/                 # 图像文件夹
```

## 主要功能

- **首页**: 展示平台核心内容和服务
- **AI工具**: AI工具资源、评测和使用指南
- **跨境电商**: 平台指南、运营策略和案例分析
- **会员服务**: 不同级别会员权益和注册

## 技术特点

- 响应式设计，适配不同设备屏幕
- 使用Flexbox和Grid进行现代布局
- 交互效果，如下拉菜单、选项卡切换等
- 平滑滚动和动画效果

## 使用说明

1. 克隆或下载此仓库
2. 在浏览器中打开index.html
3. 如需修改，可编辑相应HTML、CSS和JavaScript文件

## 注意事项

这是一个纯前端项目，目前不包含后端功能。如需实现会员注册、内容管理等功能，需要额外开发后端服务。

## 图片来源

网站中使用的图片仅供演示，实际使用时应替换为您自己的图片资源。

## 许可证

MIT License 
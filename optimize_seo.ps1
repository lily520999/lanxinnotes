# 此脚本用于优化网站所有HTML文件的SEO，添加必要的meta标签和结构化数据
# 对于每个页面，会添加：
# 1. meta description标签
# 2. meta keywords标签
# 3. 规范链接(canonical)标签
# 4. 基础结构化数据 (JSON-LD)

# 获取当前目录下所有的HTML文件
$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -Recurse

# 页面数据映射 - 为每个页面设置合适的描述和关键词
$pageData = @{
    "index.html" = @{
        "title" = "Lan Xin Notes - Professional Operation Platform"
        "description" = "Lan Xin Notes offers AI tools, cross-border e-commerce and professional tutorials to help you master operational skills and grow your business."
        "keywords" = "operation,AI tools,e-commerce,video tutorials,operation efficiency,Lan Xin Notes"
    }
    "ai-tools.html" = @{
        "title" = "AI Tools - Lan Xin Notes"
        "description" = "Explore the latest AI tool reviews and usage guides, essential assistants to improve efficiency. AI drawing, AI writing, and data analysis tools."
        "keywords" = "AI tools,AI writing,AI drawing,efficiency tools,AI reviews,Lan Xin Notes"
    }
    "ecommerce.html" = @{
        "title" = "Cross-border E-commerce - Lan Xin Notes"
        "description" = "Cross-border e-commerce platform selection, operation strategies and case studies. Amazon, TikTok Shop, Shopify platform operation guides."
        "keywords" = "cross-border e-commerce,Amazon,TikTok Shop,Shopify,e-commerce platform,operation strategy"
    }
    "articles.html" = @{
        "title" = "All Articles - Lan Xin Notes"
        "description" = "Professional operation articles provided by Lan Xin Notes, covering AI tools, cross-border e-commerce, video tutorials and more."
        "keywords" = "operation articles,AI tools,cross-border e-commerce,video marketing,content creation,member operation"
    }
    "about.html" = @{
        "title" = "About Us - Lan Xin Notes"
        "description" = "Learn about the Lan Xin Notes team, mission and values. We are committed to providing high-quality content and tools for operators."
        "keywords" = "Lan Xin Notes,about us,operation team,company introduction"
    }
    "faq.html" = @{
        "title" = "FAQ - Lan Xin Notes"
        "description" = "Frequently asked questions about Lan Xin Notes, including membership prices, content updates, platform usage and more."
        "keywords" = "FAQ,frequently asked questions,Lan Xin Notes,membership questions,usage guide"
    }
    "contact.html" = @{
        "title" = "Contact Us - Lan Xin Notes"
        "description" = "Contact the Lan Xin Notes team for professional operation consulting and support services."
        "keywords" = "contact,Lan Xin Notes,customer support,consulting services"
    }
    "privacy.html" = @{
        "title" = "Privacy Policy - Lan Xin Notes"
        "description" = "Lan Xin Notes privacy policy statement. Learn how we collect, use and protect your personal information."
        "keywords" = "privacy policy,personal information,data protection,Lan Xin Notes"
    }
    "terms.html" = @{
        "title" = "Terms of Service - Lan Xin Notes"
        "description" = "Lan Xin Notes terms of service, including conditions of use, copyright information and liability disclaimers."
        "keywords" = "terms of service,conditions of use,copyright information,Lan Xin Notes"
    }
}

# 默认数据 - 用于没有具体设置的其他页面
$defaultData = @{
    "title" = "Lan Xin Notes - Professional Operation Knowledge Sharing Platform"
    "description" = "Lan Xin Notes provides AI tool reviews, cross-border e-commerce guides and professional operation tutorials to help you improve operation capabilities and business growth."
    "keywords" = "operation,AI tools,cross-border e-commerce,video tutorials,Lan Xin Notes"
}

# 网站基本信息
$siteInfo = @{
    "name" = "Lan Xin Notes"
    "url" = "https://lanxinnotes.com"
    "logo" = "https://lanxinnotes.com/images/lanxin-logo.png"
}

# 遍历每个HTML文件
foreach ($file in $htmlFiles) {
    Write-Host "Processing file: $($file.FullName)"
    
    # 读取文件内容
    $content = Get-Content -Path $file.FullName -Raw
    
    # 获取相对路径以用作键
    $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "").Replace("\", "/")
    
    # 确定页面数据
    $data = $defaultData
    $fileName = $file.Name
    if ($pageData.ContainsKey($fileName)) {
        $data = $pageData[$fileName]
    }
    
    # 准备meta标签
    $metaTags = @"
<meta name="description" content="$($data.description)">
<meta name="keywords" content="$($data.keywords)">
<link rel="canonical" href="$($siteInfo.url)/$relativePath">
"@
    
    # 准备结构化数据
    $jsonLdWebsite = @"
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "$($siteInfo.name)",
  "url": "$($siteInfo.url)",
  "potentialAction": {
    "@type": "SearchAction",
    "target": "$($siteInfo.url)/search?q={search_term_string}",
    "query-input": "required name=search_term_string"
  }
}
</script>
"@
    
    # 为首页添加Organization结构化数据
    if ($fileName -eq "index.html") {
        $jsonLdOrganization = @"
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "$($siteInfo.name)",
  "url": "$($siteInfo.url)",
  "logo": "$($siteInfo.logo)",
  "sameAs": [
    "https://space.bilibili.com/1798377475"
  ]
}
</script>
"@
        # 组合所有结构化数据
        $structuredData = $jsonLdWebsite + "`n" + $jsonLdOrganization
    } else {
        $structuredData = $jsonLdWebsite
    }
    
    # 检查文件是否已经包含这些标签
    $hasMeta = $content -match '<meta name="description"'
    $hasCanonical = $content -match '<link rel="canonical"'
    $hasStructuredData = $content -match 'application/ld\+json'
    
    # 如果已经有这些标签，跳过
    if ($hasMeta -and $hasCanonical -and $hasStructuredData) {
        Write-Host "File already contains necessary SEO tags, skipping: $($file.FullName)"
        continue
    }
    
    # 在</head>标签前添加SEO标签和结构化数据
    $modifiedContent = $content -replace "(?i)(</head>)", "$metaTags`n$structuredData`n`$1"
    
    # 更新标题（如果需要）
    if ($data.title -and -not ($content -match [regex]::Escape($data.title))) {
        $modifiedContent = $modifiedContent -replace "(?i)(<title>)(.*?)(</title>)", "`$1$($data.title)`$3"
    }
    
    # 将修改后的内容写回文件
    Set-Content -Path $file.FullName -Value $modifiedContent -Encoding UTF8
    
    Write-Host "Successfully optimized SEO tags for: $($file.FullName)"
}

Write-Host "All HTML files SEO optimization completed!" 
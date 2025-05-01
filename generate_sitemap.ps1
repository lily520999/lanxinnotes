# 此脚本用于生成网站的sitemap.xml文件
# sitemap.xml帮助搜索引擎更好地抓取网站内容

# 网站URL
$siteUrl = "https://lanxinnotes.com"

# 获取所有HTML文件
$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -Recurse

# 创建sitemap内容
$sitemapContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
"@

# 首页优先级较高
$sitemapContent += @"
  <url>
    <loc>$siteUrl/</loc>
    <lastmod>$(Get-Date -Format "yyyy-MM-dd")</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
"@

# 添加其他页面
foreach ($file in $htmlFiles) {
    # 获取相对路径
    $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "").Replace("\", "/")
    
    # 跳过index.html，因为已经添加了根目录URL
    if ($relativePath -eq "index.html") {
        continue
    }
    
    # 根据文件类型设置优先级
    $priority = "0.7" # 默认优先级
    
    # 重要页面优先级更高
    if ($relativePath -match "^(ai-tools|ecommerce|articles)\.html$") {
        $priority = "0.9"
    } elseif ($relativePath -match "^article-.*\.html$") {
        $priority = "0.8"
    } elseif ($relativePath -match "^(about|contact|faq)\.html$") {
        $priority = "0.6"
    }
    
    # 设置更新频率
    $changefreq = "monthly"
    if ($priority -ge "0.9") {
        $changefreq = "weekly"
    }
    
    # 添加到sitemap
    $sitemapContent += @"
  <url>
    <loc>$siteUrl/$relativePath</loc>
    <lastmod>$(Get-Date $file.LastWriteTime -Format "yyyy-MM-dd")</lastmod>
    <changefreq>$changefreq</changefreq>
    <priority>$priority</priority>
  </url>
"@
}

# 关闭sitemap XML
$sitemapContent += @"
</urlset>
"@

# 写入文件
Set-Content -Path "sitemap.xml" -Value $sitemapContent

Write-Host "Sitemap.xml has been successfully generated at $(Get-Location)\sitemap.xml" 
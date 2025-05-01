# 此脚本用于在所有文章页面中添加article-schema.js脚本引用

# 获取所有文章页面
$articlePages = Get-ChildItem -Path . -Filter "article-*.html"

# 对每个文章页面添加脚本引用
foreach ($file in $articlePages) {
    Write-Host "Processing article page: $($file.Name)"
    
    # 读取文件内容
    $content = Get-Content -Path $file.FullName -Raw
    
    # 检查是否已经包含articles-schema.js脚本
    if ($content -match "articles-schema\.js") {
        Write-Host "Script already included in: $($file.Name), skipping."
        continue
    }
    
    # 在</head>标签前添加脚本引用
    $scriptTag = '<script src="articles-schema.js" defer></script>'
    $modifiedContent = $content -replace "(?i)(</head>)", "$scriptTag`n`$1"
    
    # 写回文件
    Set-Content -Path $file.FullName -Value $modifiedContent -Encoding UTF8
    
    Write-Host "Added article schema script to: $($file.Name)"
}

Write-Host "Completed adding article schema script to all article pages." 
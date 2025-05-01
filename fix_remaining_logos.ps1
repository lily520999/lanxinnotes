# 修复特定文件中未删除的哔哩哔哩LOGO图片问题
$filesToFix = @(
    "article-ai-productivity.html",
    "article-midjourney-guide.html",
    "article-chatgpt-marketing.html"
)

foreach ($file in $filesToFix) {
    Write-Host "正在处理文件: $file"
    
    if (Test-Path -Path $file) {
        $content = Get-Content -Path $file -Raw -Encoding UTF8
        $originalContent = $content
        
        # 删除页脚中的网站LOGO
        $content = $content -replace '<img src="images/lanxin-logo\.png" alt="兰心运营笔记" class="footer-logo-img">', ''
        
        # 删除导航栏中的网站LOGO
        $content = $content -replace '<img src="images/lanxin-logo\.png" alt="兰心运营笔记" class="logo-img">', ''
        
        # 删除导航栏中的哔哩哔哩图标
        $content = $content -replace '<img src="images/bilibili-logo\.png" alt="哔哩哔哩" class="bilibili-icon">', ''
        
        # 删除页脚中的哔哩哔哩频道图片
        $content = $content -replace '<img src="images/bilibili-logo\.png" alt="哔哩哔哩频道" class="footer-bilibili-img">', ''
        
        # 删除社交图标部分
        $content = $content -replace '<div class="social-icons">.*?<\/div>', ''
        
        # 检查是否有变化并保存
        if ($originalContent -ne $content) {
            Write-Host "修改并保存文件: $file"
            [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
        } else {
            Write-Host "文件没有需要修改的内容: $file"
        }
    } else {
        Write-Host "文件不存在: $file"
    }
}

Write-Host "处理完成!" 
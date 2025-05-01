@echo off
echo 删除所有HTML文件中的LOGO图片和社交图标

REM 设置PowerShell执行脚本
powershell -Command "& {
    $htmlFiles = Get-ChildItem -Path . -Recurse -Filter '*.html'
    
    foreach ($file in $htmlFiles) {
        Write-Host \"处理文件: $($file.Name)\"
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        # 删除导航栏中的网站LOGO
        $content = $content -replace '<img src=\"images/lanxin-logo\.png\" alt=\"兰心运营笔记\" class=\"logo-img\">', ''
        $content = $content -replace '<img src=\"\.\.\/images/lanxin-logo\.png\" alt=\"兰心运营笔记\" class=\"logo-img\">', ''
        
        # 删除导航栏中的哔哩哔哩图标
        $content = $content -replace '<img src=\"images/bilibili-logo\.png\" alt=\"哔哩哔哩\" class=\"bilibili-icon\">', ''
        $content = $content -replace '<img src=\"\.\.\/images/bilibili-logo\.png\" alt=\"哔哩哔哩\" class=\"bilibili-icon\">', ''
        
        # 删除页脚中的网站LOGO
        $content = $content -replace '<img src=\"images/lanxin-logo\.png\" alt=\"兰心运营笔记\" class=\"footer-logo-img\">', ''
        $content = $content -replace '<img src=\"\.\.\/images/lanxin-logo\.png\" alt=\"兰心运营笔记\" class=\"footer-logo-img\">', ''
        
        # 删除页脚中的社交图标
        $content = $content -replace '<div class=\"social-icons\">.*?<\/div>', ''
        
        # 删除页脚中的哔哩哔哩频道图片
        $content = $content -replace '<img src=\"images/bilibili-logo\.png\" alt=\"哔哩哔哩频道\" class=\"footer-bilibili-img\">', ''
        $content = $content -replace '<img src=\"\.\.\/images/bilibili-logo\.png\" alt=\"哔哩哔哩频道\" class=\"footer-bilibili-img\">', ''
        
        # 检查是否有变化并保存
        if ($originalContent -ne $content) {
            Write-Host \"修改并保存文件: $($file.Name)\"
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        }
    }
}"

echo 处理完成! 
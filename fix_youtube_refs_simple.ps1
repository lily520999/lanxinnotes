# 批量替换所有HTML文件中的youtube-logo.jpg引用为bilibili-logo.png
$htmlFiles = Get-ChildItem -Path . -Recurse -Filter "*.html"

foreach ($file in $htmlFiles) {
    Write-Host "处理文件: $($file.FullName)"
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # 替换图片引用
    $content = $content -replace "images/youtube-logo.jpg", "images/bilibili-logo.png"
    $content = $content -replace "images/youtube-logo.png", "images/bilibili-logo.png"
    $content = $content -replace "../images/youtube-logo.jpg", "../images/bilibili-logo.png"
    $content = $content -replace "../images/youtube-logo.png", "../images/bilibili-logo.png"
    
    # 替换页脚中的YouTube频道文本
    $content = $content -replace "YouTube频道", "哔哩哔哩频道"
    $content = $content -replace "前往YouTube频道", "前往哔哩哔哩频道"
    
    # 替换导航栏中的YouTube文本
    $content = $content -replace ">YouTube<", ">哔哩哔哩<"
    
    # 替换YouTube.com链接为哔哩哔哩链接
    $content = $content -replace "https://www.youtube.com/@", "https://space.bilibili.com/1798377475"
    
    # 检查是否有变化
    if ($originalContent -ne $content) {
        Write-Host "修改文件: $($file.Name)"
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
    }
}

# 修改service-worker.js
if (Test-Path "service-worker.js") {
    $swContent = Get-Content -Path "service-worker.js" -Raw -Encoding UTF8
    $modifiedSwContent = $swContent -replace "/images/youtube-logo.jpg", "/images/bilibili-logo.png"
    
    if ($swContent -ne $modifiedSwContent) {
        Write-Host "修改service-worker.js"
        [System.IO.File]::WriteAllText("service-worker.js", $modifiedSwContent, [System.Text.Encoding]::UTF8)
    }
}

Write-Host "处理完成!" 
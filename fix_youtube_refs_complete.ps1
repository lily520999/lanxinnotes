# 完整替换所有HTML文件中的YouTube引用为哔哩哔哩
$htmlFiles = Get-ChildItem -Path . -Recurse -Filter "*.html"

$totalFiles = $htmlFiles.Count
$processedFiles = 0
$modifiedFiles = 0

foreach ($file in $htmlFiles) {
    $processedFiles++
    Write-Host "处理文件 ($processedFiles/$totalFiles): $($file.FullName)"
    
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # 替换导航栏中的YouTube链接和文本
    $content = $content -replace '<a href="https://www\.youtube\.com/@[^"]*" class="nav-link[^>]*>(\s*<img[^>]*>\s*)YouTube', '<a href="https://space.bilibili.com/1798377475" class="nav-link bilibili" target="_blank">$1哔哩哔哩'
    $content = $content -replace '<a href="https://www\.youtube\.com/@[^"]*" class="nav-link[^>]*>[^<]*视频教程', '<a href="courses.html" class="nav-link">视频教程'
    
    # 替换各种YouTube图片引用
    $content = $content -replace 'images/youtube-logo\.(jpg|png)', 'images/bilibili-logo.png'
    $content = $content -replace '\.\.\/images/youtube-logo\.(jpg|png)', '../images/bilibili-logo.png'
    
    # 替换图片alt属性
    $content = $content -replace 'alt="YouTube"', 'alt="哔哩哔哩"'
    $content = $content -replace 'alt="YouTube频道"', 'alt="哔哩哔哩频道"'
    
    # 替换类名
    $content = $content -replace 'class="[^"]*youtube[^"]*"', 'class="bilibili-icon"'
    $content = $content -replace 'youtube-subscription', 'bilibili-subscription'
    $content = $content -replace 'youtube-info', 'bilibili-info'
    $content = $content -replace 'youtube-title', 'bilibili-title'
    $content = $content -replace 'youtube-description', 'bilibili-description'
    $content = $content -replace 'footer-youtube-img', 'footer-bilibili-img'
    
    # 替换页脚YouTube频道相关文本
    $content = $content -replace '<h5 class="bilibili-title">YouTube频道</h5>', '<h5 class="bilibili-title">哔哩哔哩频道</h5>'
    $content = $content -replace '前往YouTube频道</a>', '前往哔哩哔哩频道</a>'
    $content = $content -replace 'href="https://www\.youtube\.com/@[^"]*"', 'href="https://space.bilibili.com/1798377475"'
    
    # 替换文章中的YouTube增长策略链接
    $content = $content -replace '<h4 class="related-title">YouTube频道增长策略[^<]*</h4>', '<h4 class="related-title">哔哩哔哩频道增长策略：从0到10万粉丝的实战指南</h4>'
    $content = $content -replace '<a href="article-youtube-growth\.html"', '<a href="article-bilibili-growth.html"'
    
    # 替换文章内容中的YouTube为哔哩哔哩（不包括YouTube.com链接）
    $content = $content -replace '\bYouTube\b(?!\.com)', '哔哩哔哩'
    
    # 检查是否有变化
    if ($originalContent -ne $content) {
        $modifiedFiles++
        Write-Host "修改文件: $($file.Name)" -ForegroundColor Green
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
    }
}

# 修改courses.html文件中的重定向
if (Test-Path "courses.html") {
    $coursesContent = Get-Content -Path "courses.html" -Raw -Encoding UTF8
    $modifiedCoursesContent = $coursesContent -replace 'window\.location\.href = "https://www\.youtube\.com/@[^"]*";', 'window.location.href = "https://space.bilibili.com/1798377475";'
    $modifiedCoursesContent = $modifiedCoursesContent -replace '正在前往兰心运营笔记YouTube频道</h1>', '正在前往兰心运营笔记哔哩哔哩频道</h1>'
    $modifiedCoursesContent = $modifiedCoursesContent -replace '我们将在3秒内自动跳转到YouTube频道', '我们将在3秒内自动跳转到哔哩哔哩频道'
    
    if ($coursesContent -ne $modifiedCoursesContent) {
        Write-Host "修改courses.html中的重定向" -ForegroundColor Green
        [System.IO.File]::WriteAllText("courses.html", $modifiedCoursesContent, [System.Text.Encoding]::UTF8)
        $modifiedFiles++
    }
}

# 修改script.js中的YouTube嵌入链接
if (Test-Path "script.js") {
    $scriptContent = Get-Content -Path "script.js" -Raw -Encoding UTF8
    $searchPattern = 'iframe.src = "https://www.youtube.com/embed/'
    $replacePattern = 'iframe.src = "https://player.bilibili.com/player.html?bvid='
    $modifiedScriptContent = $scriptContent -replace $searchPattern, $replacePattern
    
    if ($scriptContent -ne $modifiedScriptContent) {
        Write-Host "修改script.js中的视频嵌入" -ForegroundColor Green
        [System.IO.File]::WriteAllText("script.js", $modifiedScriptContent, [System.Text.Encoding]::UTF8)
        $modifiedFiles++
    }
}

# 修改service-worker.js
if (Test-Path "service-worker.js") {
    $swContent = Get-Content -Path "service-worker.js" -Raw -Encoding UTF8
    $modifiedSwContent = $swContent -replace "'/images/youtube-logo.jpg'", "'/images/bilibili-logo.png'"
    
    if ($swContent -ne $modifiedSwContent) {
        Write-Host "修改service-worker.js中的引用" -ForegroundColor Green
        [System.IO.File]::WriteAllText("service-worker.js", $modifiedSwContent, [System.Text.Encoding]::UTF8)
        $modifiedFiles++
    }
}

Write-Host "处理完成! 共处理 $totalFiles 个文件，修改了 $modifiedFiles 个文件。" -ForegroundColor Cyan 
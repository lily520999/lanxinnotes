# 替换所有HTML文件中的YouTube图标引用为哔哩哔哩图标
# 获取所有HTML文件
$htmlFiles = Get-ChildItem -Path . -Recurse -Filter "*.html"

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # 替换导航栏中的YouTube图标
    $content = $content -replace '<img src="images/youtube-logo\.(?:png|jpg)" alt="YouTube" class="youtube-icon">', '<img src="images/bilibili-logo.png" alt="哔哩哔哩" class="bilibili-icon">'
    $content = $content -replace '<img src="\.\.\/images/youtube-logo\.(?:png|jpg)" alt="YouTube" class="youtube-icon">', '<img src="../images/bilibili-logo.png" alt="哔哩哔哩" class="bilibili-icon">'
    
    # 替换class="nav-link youtube"为class="nav-link bilibili"
    $content = $content -replace 'class="nav-link youtube"', 'class="nav-link bilibili"'
    
    # 替换页脚社交图标
    $content = $content -replace '<img src="images/youtube-logo\.(?:png|jpg)" alt="YouTube">', '<img src="images/bilibili-logo.png" alt="哔哩哔哩">'
    $content = $content -replace '<img src="\.\.\/images/youtube-logo\.(?:png|jpg)" alt="YouTube">', '<img src="../images/bilibili-logo.png" alt="哔哩哔哩">'
    
    # 替换页脚订阅区域
    $content = $content -replace 'youtube-subscription', 'bilibili-subscription'
    $content = $content -replace 'youtube-info', 'bilibili-info'
    $content = $content -replace 'youtube-title', 'bilibili-title'
    $content = $content -replace 'youtube-description', 'bilibili-description'
    $content = $content -replace 'footer-youtube-img', 'footer-bilibili-img'
    
    # 替换页脚哔哩哔哩频道图标
    $content = $content -replace '<img src="images/youtube-logo\.(?:png|jpg)" alt="哔哩哔哩频道" class="footer-(?:youtube|bilibili)-img">', '<img src="images/bilibili-logo.png" alt="哔哩哔哩频道" class="footer-bilibili-img">'
    $content = $content -replace '<img src="\.\.\/images/youtube-logo\.(?:png|jpg)" alt="哔哩哔哩频道" class="footer-(?:youtube|bilibili)-img">', '<img src="../images/bilibili-logo.png" alt="哔哩哔哩频道" class="footer-bilibili-img">'
    
    # 替换导航栏中的哔哩哔哩图标
    $content = $content -replace '<img src="images/youtube-logo\.(?:png|jpg)" alt="哔哩哔哩" class="bilibili-icon">', '<img src="images/bilibili-logo.png" alt="哔哩哔哩" class="bilibili-icon">'
    $content = $content -replace '<img src="\.\.\/images/youtube-logo\.(?:png|jpg)" alt="哔哩哔哩" class="bilibili-icon">', '<img src="../images/bilibili-logo.png" alt="哔哩哔哩" class="bilibili-icon">'
    
    # 保存修改后的内容
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}

Write-Host "Replacement complete! All YouTube references have been replaced with Bilibili references." 
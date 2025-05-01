# 删除所有HTML文件中的社交图标部分
$htmlFiles = Get-ChildItem -Path . -Recurse -Filter "*.html"

$modifiedCount = 0

foreach ($file in $htmlFiles) {
    Write-Host "处理文件: $($file.Name)"
    $content = Get-Content -Path $file.FullName -Encoding UTF8
    $newContent = @()
    $skipMode = $false
    $modified = $false
    
    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]
        
        # 检测社交图标区块开始
        if ($line -match '<div class="social-icons">') {
            $skipMode = $true
            $modified = $true
            continue
        }
        
        # 检测区块结束
        if ($skipMode -and $line -match '</div>') {
            $skipMode = $false
            continue
        }
        
        # 跳过社交图标区块内的内容
        if ($skipMode) {
            continue
        }
        
        # 删除导航栏中的哔哩哔哩图标
        if ($line -match '<img src="[^"]*bilibili-logo.png" alt="哔哩哔哩" class="bilibili-icon">') {
            $line = $line -replace '<img src="[^"]*bilibili-logo.png" alt="哔哩哔哩" class="bilibili-icon">', ''
            $modified = $true
        }
        
        # 删除页脚中的网站LOGO
        if ($line -match '<img src="[^"]*lanxin-logo.png" alt="兰心运营笔记" class="[^"]*">') {
            $line = $line -replace '<img src="[^"]*lanxin-logo.png" alt="兰心运营笔记" class="[^"]*">', ''
            $modified = $true
        }
        
        # 删除页脚中的哔哩哔哩频道图片
        if ($line -match '<img src="[^"]*bilibili-logo.png" alt="哔哩哔哩频道" class="[^"]*">') {
            $line = $line -replace '<img src="[^"]*bilibili-logo.png" alt="哔哩哔哩频道" class="[^"]*">', ''
            $modified = $true
        }
        
        $newContent += $line
    }
    
    if ($modified) {
        $modifiedCount++
        Write-Host "修改文件: $($file.Name)" -ForegroundColor Green
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
    }
}

Write-Host "处理完成! 共修改了 $modifiedCount 个文件。" -ForegroundColor Cyan 
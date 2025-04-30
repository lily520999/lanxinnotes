# 删除所有文章页面中的无效社交媒体分享链接
$articleFiles = Get-ChildItem -Path . -Filter "article-*.html"

foreach ($file in $articleFiles) {
    Write-Host "处理文件: $($file.Name)"
    $content = Get-Content -Path $file.FullName -Encoding UTF8
    $modified = $false
    $newContent = @()
    
    $inShareSection = $false
    $skipLines = 0
    
    for ($i = 0; $i -lt $content.Length; $i++) {
        $line = $content[$i]
        
        # 检测分享链接部分的开始
        if ($line -match '<div class="article-share">') {
            $inShareSection = $true
            $newContent += $line
            continue
        }
        
        # 处理分享链接区域内的内容
        if ($inShareSection) {
            # 添加标签行
            if ($line -match '<span class="share-label">') {
                $newContent += $line
                # 跳过接下来的3行 (微信、微博、LinkedIn链接)
                $skipLines = 3
                $modified = $true
                continue
            }
            
            # 跳过要删除的链接行
            if ($skipLines -gt 0) {
                $skipLines--
                continue
            }
            
            # 检测区域结束
            if ($line -match '</div>') {
                $inShareSection = $false
                $newContent += $line
                continue
            }
        }
        
        # 正常添加其他行
        $newContent += $line
    }
    
    # 如果文件被修改，则写回
    if ($modified) {
        Write-Host "修复文件: $($file.Name)"
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
    } else {
        Write-Host "文件无需修改: $($file.Name)"
    }
} 
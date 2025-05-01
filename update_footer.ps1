# 更新页脚内容脚本

# 获取所有HTML文件
$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -Recurse

# 计数器
$updatedFiles = 0
$totalFiles = $htmlFiles.Count

Write-Host "找到 $totalFiles 个HTML文件需要处理..."

# 处理每个文件
foreach ($file in $htmlFiles) {
    $filename = $file.Name
    Write-Host "处理: $filename" -NoNewline
    
    # 读取文件内容
    $content = Get-Content -Path $file.FullName -Raw
    
    # 替换页脚文本（包括问号和版权符号的情况）
    $modified = $content -replace "(\?|©) 2025 兰心运营笔记\. 保留所有权利\.", "@ 2025 兰心运营笔记. 保留所有权利."
    
    # 检查是否有更改
    if ($modified -ne $content) {
        # 写回文件
        [System.IO.File]::WriteAllText($file.FullName, $modified, [System.Text.Encoding]::UTF8)
        Write-Host " - 已更新" -ForegroundColor Green
        $updatedFiles++
    } 
    else {
        Write-Host " - 无需更改" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "所有文件处理完成：$updatedFiles/$totalFiles 个文件已更新"

# 提示用户手动提交到GitHub
Write-Host ""
Write-Host "请手动运行以下命令将更改推送到GitHub："
Write-Host "git add ."
Write-Host 'git commit -m "更新页脚符号：? 改为 @"'
Write-Host "git push origin" 
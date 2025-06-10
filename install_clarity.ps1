# 安装Microsoft Clarity分析代码到所有HTML文件

# Clarity代码
$clarityCode = @"
<script type="text/javascript">
    (function(c,l,a,r,i,t,y){
        c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
        t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
        y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
    })(window, document, "clarity", "script", "rt67r6qseo");
</script>
"@

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
    
    # 检查是否已经包含Clarity代码
    if ($content -match "clarity\.ms") {
        Write-Host " - 已存在Clarity代码" -ForegroundColor Yellow
        continue
    }
    
    # 查找</head>标签并在其前面插入Clarity代码
    if ($content -match "</head>") {
        $modified = $content -replace "</head>", "$clarityCode`r`n</head>"
        
        # 写回文件
        [System.IO.File]::WriteAllText($file.FullName, $modified, [System.Text.Encoding]::UTF8)
        Write-Host " - 已添加Clarity代码" -ForegroundColor Green
        $updatedFiles++
    } else {
        Write-Host " - 未找到</head>标签" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "所有文件处理完成：$updatedFiles/$totalFiles 个文件已更新"

# 提示用户手动提交到GitHub
Write-Host ""
Write-Host "请手动运行以下命令将更改推送到GitHub："
Write-Host "git add ."
Write-Host "git commit -m `"添加Microsoft Clarity分析代码`""
Write-Host "git push origin" 
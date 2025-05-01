# 此脚本会在所有HTML文件的<head>标签后添加Google Analytics代码
$analyticsCode = @'
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-KNR4KPK379"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-KNR4KPK379');
</script>
'@

# 获取当前目录下所有的HTML文件
$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -Recurse

# 遍历每个HTML文件
foreach ($file in $htmlFiles) {
    Write-Host "处理文件: $($file.FullName)"
    
    # 读取文件内容
    $content = Get-Content -Path $file.FullName -Raw
    
    # 检查文件是否已经包含Google Analytics代码
    if ($content -match "G-KNR4KPK379") {
        Write-Host "文件已包含Google Analytics代码，跳过: $($file.FullName)"
        continue
    }
    
    # 在<head>标签后添加Google Analytics代码
    $modifiedContent = $content -replace "(<head>)", "`$1`n$analyticsCode"
    
    # 将修改后的内容写回文件
    Set-Content -Path $file.FullName -Value $modifiedContent
    
    Write-Host "已成功添加Google Analytics代码到: $($file.FullName)"
}

Write-Host "所有HTML文件处理完成!" 
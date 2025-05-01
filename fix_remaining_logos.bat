@echo off
echo 修复特定文件中未删除的哔哩哔哩LOGO图片问题

REM 处理article-ai-productivity.html
echo 处理 article-ai-productivity.html
powershell -Command "(Get-Content -Path 'article-ai-productivity.html' -Raw) -replace '<img src=\"images/lanxin-logo\.png\" alt=\"兰心运营笔记\" class=\"logo-img\">', '' -replace '<img src=\"images/bilibili-logo\.png\" alt=\"哔哩哔哩\" class=\"bilibili-icon\">', '' -replace '<img src=\"images/lanxin-logo\.png\" alt=\"兰心运营笔记\" class=\"footer-logo-img\">', '' -replace '<img src=\"images/bilibili-logo\.png\" alt=\"哔哩哔哩频道\" class=\"footer-bilibili-img\">', '' -replace '<div class=\"social-icons\">.*?<\/div>', '' | Set-Content -Path 'article-ai-productivity.html' -Encoding UTF8"

REM 处理article-midjourney-guide.html
echo 处理 article-midjourney-guide.html
powershell -Command "(Get-Content -Path 'article-midjourney-guide.html' -Raw) -replace '<img src=\"images/lanxin-logo\.png\" alt=\"兰心运营笔记\" class=\"logo-img\">', '' -replace '<img src=\"images/bilibili-logo\.png\" alt=\"哔哩哔哩\" class=\"bilibili-icon\">', '' -replace '<img src=\"images/lanxin-logo\.png\" alt=\"兰心运营笔记\" class=\"footer-logo-img\">', '' -replace '<img src=\"images/bilibili-logo\.png\" alt=\"哔哩哔哩频道\" class=\"footer-bilibili-img\">', '' -replace '<div class=\"social-icons\">.*?<\/div>', '' | Set-Content -Path 'article-midjourney-guide.html' -Encoding UTF8"

REM 处理article-chatgpt-marketing.html
echo 处理 article-chatgpt-marketing.html
powershell -Command "(Get-Content -Path 'article-chatgpt-marketing.html' -Raw) -replace '<img src=\"images/lanxin-logo\.png\" alt=\"兰心运营笔记\" class=\"logo-img\">', '' -replace '<img src=\"images/bilibili-logo\.png\" alt=\"哔哩哔哩\" class=\"bilibili-icon\">', '' -replace '<img src=\"images/lanxin-logo\.png\" alt=\"兰心运营笔记\" class=\"footer-logo-img\">', '' -replace '<img src=\"images/bilibili-logo\.png\" alt=\"哔哩哔哩频道\" class=\"footer-bilibili-img\">', '' -replace '<div class=\"social-icons\">.*?<\/div>', '' | Set-Content -Path 'article-chatgpt-marketing.html' -Encoding UTF8"

echo 处理完成! 
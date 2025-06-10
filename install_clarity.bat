@echo off
echo Installing Microsoft Clarity code...

:: Run PowerShell command to add Clarity code
powershell -Command "$clarityCode = '<script type=\"text/javascript\">' + [Environment]::NewLine + '    (function(c,l,a,r,i,t,y){' + [Environment]::NewLine + '        c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};' + [Environment]::NewLine + '        t=l.createElement(r);t.async=1;t.src=\"https://www.clarity.ms/tag/\"+i;' + [Environment]::NewLine + '        y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);' + [Environment]::NewLine + '    })(window, document, \"clarity\", \"script\", \"rt67r6qseo\");' + [Environment]::NewLine + '</script>'; Get-ChildItem -Path . -Filter '*.html' -Recurse | ForEach-Object { $content = Get-Content -Path $_.FullName -Raw; if ($content -notmatch 'clarity\.ms') { if ($content -match '</head>') { $modified = $content -replace '</head>', ($clarityCode + [Environment]::NewLine + '</head>'); [System.IO.File]::WriteAllText($_.FullName, $modified, [System.Text.Encoding]::UTF8); Write-Host ('Added Clarity to: ' + $_.Name) } } else { Write-Host ('Clarity already exists in: ' + $_.Name) } }"

echo.
echo Installation completed!
echo.
echo Please run the following commands to push changes to GitHub:
echo git add .
echo git commit -m "Add Microsoft Clarity analytics code"
echo git push origin

pause 
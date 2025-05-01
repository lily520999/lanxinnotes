@echo off
echo Updating footer content...

:: Run PowerShell command to replace footer text
powershell -Command "Get-ChildItem -Path . -Filter '*.html' -Recurse | ForEach-Object { $content = Get-Content -Path $_.FullName -Raw; $modified = $content -replace '(\?|©) 2025 兰心运营笔记\. 保留所有权利\.', '@ 2025 兰心运营笔记. 保留所有权利.'; if ($modified -ne $content) { [System.IO.File]::WriteAllText($_.FullName, $modified, [System.Text.Encoding]::UTF8); Write-Host ('Updated: ' + $_.Name) } }"

echo.
echo Update completed!
echo.
echo Please run the following commands to push changes to GitHub:
echo git add .
echo git commit -m "Update footer symbol: ? to @"
echo git push origin

pause 
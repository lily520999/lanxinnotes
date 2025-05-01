@echo off
echo Website Performance Optimization Toolkit
echo ===============================
echo.

echo This tool will perform the following optimizations:
echo 1. Add image lazy loading and compress HTML
echo 2. Compress CSS and JavaScript files
echo 3. Analyze and provide image optimization recommendations
echo.

echo Note: All optimizations will create backup files, which you can restore at any time
echo.

:PROMPT
set /p choice=Continue? (Y/N): 
if /i "%choice%" EQU "Y" goto RUN
if /i "%choice%" EQU "N" goto END
goto PROMPT

:RUN
echo.
echo Executing optimizations...
echo.

echo Step 1: Basic website optimization (image lazy loading, HTML compression)
powershell -ExecutionPolicy Bypass -File optimize_website.ps1
echo.

echo Step 2: Compress CSS and JavaScript resources
powershell -ExecutionPolicy Bypass -File compress_assets.ps1
echo.

echo Step 3: Image analysis and optimization recommendations
powershell -ExecutionPolicy Bypass -File optimize_images.ps1
echo.

echo All optimizations completed!
echo.
echo Additional recommendations for improving website loading performance:
echo - Consider using a Content Delivery Network (CDN) to host static resources
echo - Implement browser caching control policies
echo - Consider using HTTP/2 or HTTP/3 protocol
echo - Use web server compression (gzip or brotli)
echo - Reduce third-party scripts and resources
echo.
goto END

:END
echo Thank you for using the Website Performance Optimization Toolkit!
pause 
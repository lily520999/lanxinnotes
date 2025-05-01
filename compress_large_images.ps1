# Large image compression script
# This script identifies large images and copies them to a folder for manual optimization
# You'll need to manually compress these images using tools like TinyPNG or ImageMagick

Write-Host "Large Image Compression Helper"
Write-Host "=============================="
Write-Host "This script will identify large images that slow down your website"
Write-Host "and prepare them for optimization."

# Create directory for large images
$largeImagesDir = "images_to_optimize"
if (-not (Test-Path $largeImagesDir)) {
    New-Item -Path $largeImagesDir -ItemType Directory | Out-Null
    Write-Host "Created directory: $largeImagesDir"
}

# Find large images (>100KB)
Write-Host "`nSearching for large images..."
$imageFiles = Get-ChildItem -Path . -Recurse -Include "*.jpg","*.jpeg","*.png","*.gif" | 
    Where-Object { ($_.Length -gt 100KB) -and ($_.Directory.Name -like "images*" -or $_.Directory.FullName -match "images") }

if ($imageFiles.Count -eq 0) {
    Write-Host "No large image files found."
    exit
}

# Create report file with optimization recommendations
$reportFile = "$largeImagesDir\optimization_report.txt"
$report = @"
LARGE IMAGES OPTIMIZATION REPORT
================================
Generated: $(Get-Date)

The following large images were found on your website:

"@

$totalSize = 0
$largeImagesTable = @()

foreach ($img in $imageFiles) {
    $size = $img.Length
    $totalSize += $size
    
    # Copy file to optimization directory
    $destPath = Join-Path -Path $largeImagesDir -ChildPath $img.Name
    Copy-Item -Path $img.FullName -Destination $destPath -Force
    
    # Add to report
    $largeImagesTable += [PSCustomObject]@{
        FileName = $img.Name
        Path = $img.FullName
        Size = "{0:N2} KB" -f ($size / 1KB)
        OptimizationGoal = "{0:N2} KB" -f (($size / 1KB) * 0.5) # Target 50% reduction
    }
}

# Add table to report
$largeImagesTable | Format-Table -AutoSize | Out-String | ForEach-Object { $report += $_ }

# Add recommendations to report
$report += @"

OPTIMIZATION RECOMMENDATIONS
===========================
1. Use TinyPNG (https://tinypng.com/) for the best quality/compression ratio
2. Target file sizes should be around 50% of the original size
3. For each image, consider:
   - Can it be converted to WebP format? (better compression)
   - Can it be resized to be smaller?
   - Is it necessary, or can it be removed?
4. After optimization, replace the original files with the optimized versions

WebP CONVERSION INSTRUCTIONS
===========================
If you have ImageMagick installed, you can use this command to convert to WebP:
magick convert [original-image.jpg] -quality 80 [new-image.webp]

Or use online WebP converters:
- https://squoosh.app/
- https://ezgif.com/png-to-webp
- https://convertio.co/jpg-webp/

TOTAL POTENTIAL SAVINGS
======================
Current total size of large images: $([math]::Round($totalSize / 1KB, 2)) KB
Potential optimized size: $([math]::Round($totalSize / 1KB * 0.5, 2)) KB
Potential savings: $([math]::Round($totalSize / 1KB * 0.5, 2)) KB
"@

# Save report
$report | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host "Found $($imageFiles.Count) large images, total size: $([math]::Round($totalSize / 1MB, 2)) MB"
Write-Host "Images copied to '$largeImagesDir' directory for optimization"
Write-Host "Full report available at: $reportFile"
Write-Host "`nAfter manually optimizing these images, replace the originals with your optimized versions."
Write-Host "This could potentially save $([math]::Round($totalSize / 1MB * 0.5, 2)) MB of load time."

# Create HTML optimization guide
$htmlGuideFile = "$largeImagesDir\optimization_guide.html"
$htmlGuide = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Image Optimization Guide</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
            text-align: left;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        h1, h2 {
            color: #333;
        }
        .tips {
            background-color: #f0f7ff;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .button {
            display: inline-block;
            padding: 10px 15px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        .button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <h1>Image Optimization Guide</h1>
    <p>Generated: $(Get-Date)</p>
    
    <div class="tips">
        <h2>Why Optimize Images?</h2>
        <p>Large images significantly slow down your website loading time. By optimizing these images, you can improve:</p>
        <ul>
            <li>Page load speed (better user experience)</li>
            <li>SEO rankings (search engines prefer fast websites)</li>
            <li>Bandwidth usage (saves data for mobile users)</li>
            <li>Conversion rates (faster sites convert better)</li>
        </ul>
    </div>
    
    <h2>Images to Optimize</h2>
    <p>The following large images were found on your website:</p>
    
    <table>
        <tr>
            <th>Filename</th>
            <th>Current Size</th>
            <th>Target Size</th>
            <th>Path</th>
        </tr>
"@

# Add image rows to HTML
foreach ($img in $largeImagesTable) {
    $htmlGuide += @"
        <tr>
            <td>$($img.FileName)</td>
            <td>$($img.Size)</td>
            <td>$($img.OptimizationGoal)</td>
            <td>$($img.Path)</td>
        </tr>
"@
}

# Complete the HTML
$htmlGuide += @"
    </table>
    
    <h2>How to Optimize</h2>
    <ol>
        <li>Use one of the following tools:
            <ul>
                <li><a href="https://tinypng.com/" target="_blank">TinyPNG</a> - Best quality/compression ratio for PNG/JPEG</li>
                <li><a href="https://squoosh.app/" target="_blank">Squoosh</a> - Google's tool with many compression options</li>
                <li><a href="https://imageoptim.com/" target="_blank">ImageOptim</a> - Desktop app for Mac</li>
                <li><a href="https://ezgif.com/optimize" target="_blank">EZGIF</a> - Online image optimizer</li>
            </ul>
        </li>
        <li>Aim for 50% file size reduction while maintaining acceptable quality</li>
        <li>Consider converting to WebP format for better compression (with JPEG/PNG fallbacks for older browsers)</li>
        <li>Replace the original files with your optimized versions</li>
    </ol>
    
    <div class="tips">
        <h2>Advanced Tips</h2>
        <ul>
            <li>Properly size images - don't use a 2000px image for a 400px container</li>
            <li>Use responsive images with the <code>&lt;picture&gt;</code> element and <code>srcset</code> attribute</li>
            <li>Implement lazy loading for images below the fold</li>
            <li>Remove unnecessary images entirely if they don't add value</li>
        </ul>
    </div>
    
    <h2>Potential Savings</h2>
    <p>Current total size of large images: <strong>$([math]::Round($totalSize / 1KB, 2)) KB</strong></p>
    <p>Potential optimized size: <strong>$([math]::Round($totalSize / 1KB * 0.5, 2)) KB</strong></p>
    <p>Potential savings: <strong>$([math]::Round($totalSize / 1KB * 0.5, 2)) KB</strong></p>
    
    <p><a class="button" href="https://tinypng.com/" target="_blank">Start Optimizing with TinyPNG</a></p>
</body>
</html>
"@

# Save HTML guide
$htmlGuide | Out-File -FilePath $htmlGuideFile -Encoding UTF8
Write-Host "HTML optimization guide created at: $htmlGuideFile"
Write-Host "Open this HTML file in your browser for a more detailed guide." 
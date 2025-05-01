# Image optimization script
# Note: This script requires PowerShell module NtImageProcessor or external tools
# By default, it will provide guidance but won't actually optimize images

Write-Host "Image Optimization Guide"
Write-Host "======================="
Write-Host "Image optimization is one of the most important factors for improving load speed."
Write-Host "Since PowerShell doesn't include image processing functionality by default, here are several image optimization methods:"

function Show-ImageOptimizationTools {
    Write-Host "`n1. Use online tools to compress images:"
    Write-Host "   - TinyPNG (https://tinypng.com/): Provides high-quality PNG and JPEG compression"
    Write-Host "   - Squoosh (https://squoosh.app/): Google-developed image compression tool, supports multiple formats"
    Write-Host "   - Compressor.io: Image compression tool that maintains high quality"
    
    Write-Host "`n2. Use local/command-line tools:"
    Write-Host "   - ImageMagick: Powerful image processing tool"
    Write-Host "   - PNGQuant: Specifically for PNG image compression"
    Write-Host "   - JPEGOptim: Optimization tool for JPEG images"
    
    Write-Host "`n3. Image format conversion suggestions:"
    Write-Host "   - Use WebP format instead of JPEG and PNG, can save 30-50% file size"
    Write-Host "   - Use AVIF format for better compression rates (emerging format, browser support still developing)"
}

function Analyze-ImagesOnWebsite {
    Write-Host "`nAnalyzing website images..."
    $imageFiles = Get-ChildItem -Path . -Recurse -Include "*.jpg","*.jpeg","*.png","*.gif" | 
        Where-Object { $_.Directory.Name -like "images*" -or $_.Directory.FullName -match "images" }
    
    if ($imageFiles.Count -eq 0) {
        Write-Host "No image files found."
        return
    }
    
    $totalSize = 0
    $largeImages = @()
    $mediumImages = @()
    
    foreach ($img in $imageFiles) {
        $size = $img.Length
        $totalSize += $size
        
        # Images larger than 100KB are considered large
        if ($size -gt 100KB) {
            $largeImages += [PSCustomObject]@{
                FileName = $img.Name
                Path = $img.FullName
                Size = "{0:N2} KB" -f ($size / 1KB)
            }
        }
        # Images 50KB-100KB are considered medium-sized
        elseif ($size -gt 50KB) {
            $mediumImages += [PSCustomObject]@{
                FileName = $img.Name
                Path = $img.FullName
                Size = "{0:N2} KB" -f ($size / 1KB)
            }
        }
    }
    
    Write-Host "Found $($imageFiles.Count) image files, total size: $([math]::Round($totalSize / 1MB, 2)) MB"
    
    if ($largeImages.Count -gt 0) {
        Write-Host "`nLarge images that need priority optimization (>100KB):"
        $largeImages | Format-Table -AutoSize
    }
    
    if ($mediumImages.Count -gt 0) {
        Write-Host "`nMedium-sized images recommended for optimization (50KB-100KB):"
        $mediumImages | Format-Table -AutoSize
    }
    
    Write-Host "`nOptimization recommendations:"
    Write-Host "1. Large images should be compressed to 30-50% of original size while maintaining appropriate quality"
    Write-Host "2. Website thumbnails should be controlled to 10-30KB in size"
    Write-Host "3. Background images and large banners should use progressive JPEG or WebP format"
    Write-Host "4. Consider providing responsive images for different screen sizes"
}

function Create-ResponsiveImageGuide {
    Write-Host "`nResponsive Image HTML Implementation Guide:"
    Write-Host "Use <picture> and srcset attributes to provide images for different resolutions:"
    
    Write-Host @"
<!-- Responsive image example -->
<picture>
  <!-- Modern browsers use WebP format -->
  <source srcset="images/example-small.webp 480w,
                 images/example-medium.webp 800w,
                 images/example-large.webp 1200w"
          type="image/webp">
  <!-- Fallback to JPEG format -->
  <source srcset="images/example-small.jpg 480w,
                 images/example-medium.jpg 800w,
                 images/example-large.jpg 1200w"
          type="image/jpeg">
  <!-- Default fallback image -->
  <img src="images/example-medium.jpg"
       alt="Example image"
       loading="lazy"
       width="800" height="600">
</picture>
"@
    
    Write-Host "`nHandle responsive background images with CSS:"
    Write-Host @"
/* Responsive background image example */
.hero-background {
  background-image: url('images/background-small.jpg');
}

@media (min-width: 768px) {
  .hero-background {
    background-image: url('images/background-medium.jpg');
  }
}

@media (min-width: 1200px) {
  .hero-background {
    background-image: url('images/background-large.jpg');
  }
}
"@
}

function Create-LazyLoadingGuide {
    Write-Host "`nImage Lazy Loading Implementation Guide:"
    Write-Host "1. Use native lazy loading in modern browsers:"
    Write-Host @"
<img src="image.jpg" loading="lazy" alt="Description text">
"@
    
    Write-Host "`n2. Use JavaScript to implement custom lazy loading (for more complex scenarios):"
    Write-Host @"
<img data-src="image.jpg" class="lazy" alt="Description text">

<script>
// Simple lazy loading implementation
document.addEventListener("DOMContentLoaded", function() {
  const lazyImages = document.querySelectorAll("img.lazy");
  
  // Use Intersection Observer API
  if ("IntersectionObserver" in window) {
    let lazyImageObserver = new IntersectionObserver(function(entries, observer) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          let lazyImage = entry.target;
          lazyImage.src = lazyImage.dataset.src;
          lazyImage.classList.remove("lazy");
          lazyImageObserver.unobserve(lazyImage);
        }
      });
    });
    
    lazyImages.forEach(function(lazyImage) {
      lazyImageObserver.observe(lazyImage);
    });
  } else {
    // Fallback to traditional method
    // ...
  }
});
</script>
"@
}

# Image analysis and recommendations
Show-ImageOptimizationTools
Analyze-ImagesOnWebsite
Create-ResponsiveImageGuide
Create-LazyLoadingGuide

Write-Host "`nImage Optimization Summary:"
Write-Host "1. Analyze and optimize all large images, prioritize those over 100KB"
Write-Host "2. Convert images to WebP format (with JPEG/PNG as fallback)"
Write-Host "3. Provide images of different sizes for different devices"
Write-Host "4. Use lazy loading techniques to delay loading images outside the initial viewport"
Write-Host "5. Ensure all images have correct width and height attributes to avoid layout shifts"
Write-Host "6. Consider using a CDN service to distribute image resources"

Write-Host "`nTo automate these tasks, it's recommended to use image processing tools like ImageMagick, and NPM tools like imagemin." 
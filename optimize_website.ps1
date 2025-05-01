# Website performance optimization script
Write-Host "Starting website performance optimization..."

# 1. Add lazy loading attribute to images
function Add-LazyLoading {
    Write-Host "Adding lazy loading attribute to images..."
    $htmlFiles = Get-ChildItem -Path . -Recurse -Filter "*.html"
    
    foreach ($file in $htmlFiles) {
        Write-Host "Processing file: $($file.Name)"
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        # Add loading="lazy" attribute to all img tags that don't already have it
        $content = $content -replace '(<img[^>]+)(?!loading=)(.*?>)', '$1 loading="lazy"$2'
        
        # Add width and height attributes to reduce layout shift
        $content = $content -replace '(<img[^>]+class="logo-img"[^>]*)(>)', '$1 width="40" height="40"$2'
        $content = $content -replace '(<img[^>]+class="bilibili-icon"[^>]*)(>)', '$1 width="24" height="24"$2'
        
        # Check if there were changes and save
        if ($originalContent -ne $content) {
            Write-Host "Added lazy loading attributes to: $($file.Name)"
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        }
    }
}

# 2. Compress HTML files
function Compress-HtmlFiles {
    Write-Host "Compressing HTML files..."
    $htmlFiles = Get-ChildItem -Path . -Recurse -Filter "*.html"
    
    foreach ($file in $htmlFiles) {
        Write-Host "Compressing file: $($file.Name)"
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        # Remove HTML comments (preserving conditional comments)
        $content = $content -replace '(?<!\/\/)<!--(?!(\[if|\[endif)).*?-->', ''
        
        # Remove unnecessary whitespace
        $content = $content -replace '>\s+<', '><'
        $content = $content -replace '[\t ]+', ' '
        $content = $content -replace '[\r\n]+', "`n"
        
        # Save compressed content
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
    }
}

# 3. Add cache control header guidelines
function Show-CacheControlGuide {
    Write-Host "`nCache Control Guidelines:"
    Write-Host "Add the following cache control headers on your server to optimize loading speed:"
    Write-Host "For HTML files: Cache-Control: no-cache"
    Write-Host "For CSS/JS files: Cache-Control: public, max-age=31536000"
    Write-Host "For image files: Cache-Control: public, max-age=31536000, immutable"
    Write-Host "If using Nginx server, you can add the following configuration:"
    Write-Host "  location ~* \.(jpg|jpeg|png|gif|ico)$ {"
    Write-Host "    expires 1y;"
    Write-Host "    add_header Cache-Control 'public, max-age=31536000, immutable';"
    Write-Host "  }"
    Write-Host "  location ~* \.(css|js)$ {"
    Write-Host "    expires 1y;"
    Write-Host "    add_header Cache-Control 'public, max-age=31536000';"
    Write-Host "  }"
}

# 4. Create preload links for critical resources
function Add-Preload {
    Write-Host "Adding preload tags..."
    $indexFile = "index.html"
    
    if (Test-Path $indexFile) {
        $content = Get-Content -Path $indexFile -Raw -Encoding UTF8
        $originalContent = $content
        
        # Add preload links in head
        $preloadTags = @"
    <link rel="preload" href="styles.css" as="style">
    <link rel="preload" href="script.js" as="script">
"@
        
        # Add preload tags before </head>
        $content = $content -replace '(</head>)', "$preloadTags`n`$1"
        
        # Check if there were changes and save
        if ($originalContent -ne $content) {
            Write-Host "Added preload tags to: $indexFile"
            [System.IO.File]::WriteAllText($indexFile, $content, [System.Text.Encoding]::UTF8)
        }
    } else {
        Write-Host "Index file not found: $indexFile"
    }
}

# 5. Create recommended .htaccess file guide (for Apache servers)
function Create-HtaccessGuide {
    Write-Host "`n.htaccess Guide (for Apache servers):"
    $htaccessContent = @"
# Enable compression
<IfModule mod_deflate.c>
  # Compress HTML, CSS, JavaScript, Text, XML and other content types
  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css application/javascript application/x-javascript

  # Remove browser bugs for browsers that don't handle compression well
  BrowserMatch ^Mozilla/4 gzip-only-text/html
  BrowserMatch ^Mozilla/4\.0[678] no-gzip
  BrowserMatch \bMSIE !no-gzip !gzip-only-text/html
</IfModule>

# Set cache control
<IfModule mod_expires.c>
  ExpiresActive On
  
  # Default cache for 1 month
  ExpiresDefault "access plus 1 month"
  
  # HTML documents
  ExpiresByType text/html "access plus 0 seconds"
  
  # CSS and JavaScript files cache for 1 year
  ExpiresByType text/css "access plus 1 year"
  ExpiresByType application/javascript "access plus 1 year"
  
  # Image files cache for 1 year
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType image/webp "access plus 1 year"
  
  # Font files cache for 1 year
  ExpiresByType application/font-woff "access plus 1 year"
  ExpiresByType application/font-woff2 "access plus 1 year"
  ExpiresByType application/x-font-ttf "access plus 1 year"
</IfModule>
"@
    Write-Host $htaccessContent
    
    # Optional: Create an example .htaccess file
    $htaccessFile = ".htaccess.example"
    $htaccessContent | Set-Content -Path $htaccessFile -Encoding UTF8
    Write-Host "Created example .htaccess file: $htaccessFile"
}

# 6. Add inline critical CSS recommendations
function Create-CriticalCssGuide {
    Write-Host "`nCritical CSS Inlining Recommendations:"
    Write-Host "Inlining critical CSS in HTML can speed up first render. Follow these steps:"
    Write-Host "1. Extract critical CSS (styles for above-the-fold elements)"
    Write-Host "2. Place these CSS in a <style> tag and add to the <head> section"
    Write-Host "3. For remaining CSS, keep using external stylesheets and add async loading"
    Write-Host "Example:"
    Write-Host "<head>"
    Write-Host "  <!-- Inline critical CSS -->"
    Write-Host "  <style>"
    Write-Host "    /* Above-the-fold critical styles */"
    Write-Host "    .header { ... }"
    Write-Host "    .hero { ... }"
    Write-Host "  </style>"
    Write-Host "  <!-- Async load full CSS -->"
    Write-Host "  <link rel=\"preload\" href=\"styles.css\" as=\"style\" onload=\"this.onload=null;this.rel='stylesheet'\">"
    Write-Host "  <noscript><link rel=\"stylesheet\" href=\"styles.css\"></noscript>"
    Write-Host "</head>"
}

# Execute optimization functions
Add-LazyLoading
Compress-HtmlFiles
Add-Preload
Show-CacheControlGuide
Create-HtaccessGuide
Create-CriticalCssGuide

Write-Host "`nWebsite performance optimization completed!"
Write-Host "Note: These are basic improvements, you may need to make further optimizations based on your specific situation." 
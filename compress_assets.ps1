# Website resource compression script
Write-Host "Starting website resource compression..."

function Compress-CssFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    Write-Host "Compressing CSS file: $FilePath"
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    
    # Backup original file
    $backupPath = "$FilePath.backup"
    if (-not (Test-Path $backupPath)) {
        Copy-Item -Path $FilePath -Destination $backupPath
    }
    
    # Remove comments
    $content = $content -replace '/\*[\s\S]*?\*/', ''
    
    # Remove extra whitespace
    $content = $content -replace '\s+', ' '
    $content = $content -replace ': ', ':'
    $content = $content -replace ' \{', '{'
    $content = $content -replace '\} ', '}'
    $content = $content -replace ';\}', '}'
    $content = $content -replace ', ', ','
    $content = $content -replace '; ', ';'
    
    # Save compressed content
    [System.IO.File]::WriteAllText($FilePath, $content, [System.Text.Encoding]::UTF8)
    
    # Report compression effect
    $originalSize = (Get-Item -Path $backupPath).Length
    $compressedSize = (Get-Item -Path $FilePath).Length
    $savingsPercent = [math]::Round(($originalSize - $compressedSize) / $originalSize * 100, 2)
    
    Write-Host "  Original size: $originalSize bytes"
    Write-Host "  Compressed: $compressedSize bytes"
    Write-Host "  Savings: $savingsPercent%"
}

function Compress-JsFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    Write-Host "Compressing JavaScript file: $FilePath"
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    
    # Backup original file
    $backupPath = "$FilePath.backup"
    if (-not (Test-Path $backupPath)) {
        Copy-Item -Path $FilePath -Destination $backupPath
    }
    
    # Simple compression (Note: This is just basic compression, full compression requires professional tools like UglifyJS)
    # Remove single-line comments
    $content = $content -replace '//.*?$', ''
    
    # Remove multi-line comments
    $content = $content -replace '/\*[\s\S]*?\*/', ''
    
    # Remove extra whitespace
    $content = $content -replace '\s+', ' '
    $content = $content -replace ': ', ':'
    $content = $content -replace ' \{', '{'
    $content = $content -replace '\} ', '}'
    $content = $content -replace '; ', ';'
    
    # Save compressed content
    [System.IO.File]::WriteAllText($FilePath, $content, [System.Text.Encoding]::UTF8)
    
    # Report compression effect
    $originalSize = (Get-Item -Path $backupPath).Length
    $compressedSize = (Get-Item -Path $FilePath).Length
    $savingsPercent = [math]::Round(($originalSize - $compressedSize) / $originalSize * 100, 2)
    
    Write-Host "  Original size: $originalSize bytes"
    Write-Host "  Compressed: $compressedSize bytes"
    Write-Host "  Savings: $savingsPercent%"
}

function Create-CombinedJs {
    Write-Host "Creating combined JavaScript file..."
    $jsFiles = Get-ChildItem -Path . -Filter "*.js" | Where-Object { !$_.Name.Contains(".min.") -and !$_.Name.StartsWith("combined") -and !$_.FullName.EndsWith(".backup") }
    
    if ($jsFiles.Count -gt 1) {
        $combinedContent = ""
        foreach ($file in $jsFiles) {
            $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
            $combinedContent += "/* $($file.Name) */`n$content`n"
        }
        
        # Save combined file
        $combinedFile = "combined.min.js"
        [System.IO.File]::WriteAllText($combinedFile, $combinedContent, [System.Text.Encoding]::UTF8)
        
        # Compress combined file
        Compress-JsFile -FilePath $combinedFile
        
        Write-Host "Created combined JavaScript file: $combinedFile"
        Write-Host "Tip: Please update <script> tags in HTML to reference this file"
    } else {
        Write-Host "Not enough JavaScript files found to combine"
    }
}

function Create-CombinedCss {
    Write-Host "Creating combined CSS file..."
    $cssFiles = Get-ChildItem -Path . -Filter "*.css" | Where-Object { !$_.Name.Contains(".min.") -and !$_.Name.StartsWith("combined") -and !$_.FullName.EndsWith(".backup") }
    
    if ($cssFiles.Count -gt 1) {
        $combinedContent = ""
        foreach ($file in $cssFiles) {
            $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
            $combinedContent += "/* $($file.Name) */`n$content`n"
        }
        
        # Save combined file
        $combinedFile = "combined.min.css"
        [System.IO.File]::WriteAllText($combinedFile, $combinedContent, [System.Text.Encoding]::UTF8)
        
        # Compress combined file
        Compress-CssFile -FilePath $combinedFile
        
        Write-Host "Created combined CSS file: $combinedFile"
        Write-Host "Tip: Please update <link> tags in HTML to reference this file"
    } else {
        Write-Host "Not enough CSS files found to combine"
    }
}

function Add-FileVersioning {
    Write-Host "Adding version control parameters to resources..."
    # Fix: Use two separate commands for CSS and JS files
    $cssFiles = Get-ChildItem -Path . -Filter "*.css" | Where-Object { !$_.FullName.EndsWith(".backup") }
    $jsFiles = Get-ChildItem -Path . -Filter "*.js" | Where-Object { !$_.FullName.EndsWith(".backup") }
    $htmlFiles = Get-ChildItem -Path . -Recurse -Filter "*.html"
    
    # Process CSS files
    foreach ($file in $cssFiles) {
        $fileHash = Get-FileHash -Path $file.FullName -Algorithm MD5
        $shortHash = $fileHash.Hash.Substring(0, 8).ToLower()
        
        foreach ($htmlFile in $htmlFiles) {
            $content = Get-Content -Path $htmlFile.FullName -Raw -Encoding UTF8
            $originalContent = $content
            
            # Add version number to CSS references
            $content = $content -replace "href=([""'])$($file.Name)([""'])", "href=`$1$($file.Name)?v=$shortHash`$2"
            
            if ($originalContent -ne $content) {
                [System.IO.File]::WriteAllText($htmlFile.FullName, $content, [System.Text.Encoding]::UTF8)
                Write-Host "  Updated CSS reference $($file.Name) in $($htmlFile.Name) to add version number"
            }
        }
    }
    
    # Process JS files
    foreach ($file in $jsFiles) {
        $fileHash = Get-FileHash -Path $file.FullName -Algorithm MD5
        $shortHash = $fileHash.Hash.Substring(0, 8).ToLower()
        
        foreach ($htmlFile in $htmlFiles) {
            $content = Get-Content -Path $htmlFile.FullName -Raw -Encoding UTF8
            $originalContent = $content
            
            # Add version number to JS references
            $content = $content -replace "src=([""'])$($file.Name)([""'])", "src=`$1$($file.Name)?v=$shortHash`$2"
            
            if ($originalContent -ne $content) {
                [System.IO.File]::WriteAllText($htmlFile.FullName, $content, [System.Text.Encoding]::UTF8)
                Write-Host "  Updated JS reference $($file.Name) in $($htmlFile.Name) to add version number"
            }
        }
    }
}

# Execute compression functions
# First compress individual CSS files
$cssFiles = Get-ChildItem -Path . -Filter "*.css" | Where-Object { !$_.Name.Contains(".min.") -and !$_.FullName.EndsWith(".backup") }
foreach ($cssFile in $cssFiles) {
    Compress-CssFile -FilePath $cssFile.FullName
}

# Then compress individual JS files
$jsFiles = Get-ChildItem -Path . -Filter "*.js" | Where-Object { !$_.Name.Contains(".min.") -and !$_.FullName.EndsWith(".backup") }
foreach ($jsFile in $jsFiles) {
    Compress-JsFile -FilePath $jsFile.FullName
}

# Create combined files (uncomment as needed)
# Create-CombinedCss
# Create-CombinedJs

# Add file versioning (cache busting)
Add-FileVersioning

Write-Host "`nWebsite resource compression completed!"
Write-Host "Tip: For more advanced JavaScript compression, consider using professional tools like UglifyJS or terser."
Write-Host "     Backups of each original file have been saved with the .backup extension." 
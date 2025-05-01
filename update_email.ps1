# Update email addresses and remove specific text

# Get all HTML files
$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -Recurse

# Process each file
foreach ($file in $htmlFiles) {
    $filename = $file.Name
    Write-Host "Processing: $filename"
    
    # Read file content
    $content = Get-Content -Path $file.FullName -Raw
    
    # Replace email address
    $modified = $content.Replace("contact@lanxin-notes.com", "contact@lanxinnotes.com")
    
    # Remove specific text (using hex code for Chinese characters to avoid encoding issues)
    $modified = $modified.Replace([System.Text.Encoding]::Unicode.GetString([System.Text.Encoding]::Unicode.GetBytes("工作日24小时内回复")), "")
    
    # Write back if changed
    if ($modified -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $modified, [System.Text.Encoding]::UTF8)
        Write-Host "Updated: $filename"
    }
}

# Get all JS files
$jsFiles = Get-ChildItem -Path . -Filter "*.js" -Recurse

# Process each JS file
foreach ($file in $jsFiles) {
    $filename = $file.Name
    Write-Host "Processing JS: $filename"
    
    # Read file content
    $content = Get-Content -Path $file.FullName -Raw
    
    # Replace email address
    $modified = $content.Replace("contact@lanxin-notes.com", "contact@lanxinnotes.com")
    
    # Remove specific text (using hex code for Chinese characters to avoid encoding issues)
    $modified = $modified.Replace([System.Text.Encoding]::Unicode.GetString([System.Text.Encoding]::Unicode.GetBytes("工作日24小时内回复")), "")
    
    # Write back if changed
    if ($modified -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $modified, [System.Text.Encoding]::UTF8)
        Write-Host "Updated JS: $filename"
    }
}

Write-Host "All files processed" 
# Simple script to update email and remove text

# Get all HTML and JS files
$files = Get-ChildItem -Path . -Recurse -Include "*.html","*.js"

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Do the replacements
    $newContent = $content.Replace("contact@lanxin-notes.com", "contact@lanxinnotes.com")
    $newContent = $newContent.Replace("工作日24小时内回复", "")
    
    # Write back if changed
    if ($newContent -ne $content) {
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
        Write-Host "Updated: $($file.Name)"
    }
}

Write-Host "All files processed" 
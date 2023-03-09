if (Get-Command "trufflehog" -errorAction SilentlyContinue) {
    Write-Host -ForegroundColor Yellow "trufflehog already install... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing trufflehog"
    pip install trufflehog
}

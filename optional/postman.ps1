if (Get-Command "postman" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "Postman already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing Postman"

    choco install -y postman
    refreshenv
}

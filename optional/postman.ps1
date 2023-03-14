if (choco list postman -l | Select-String -pattern "1 packages installed." -quiet)
{    
    Write-Host -ForegroundColor Yellow "Postman already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing Postman"

    choco install -y postman
    refreshenv
}

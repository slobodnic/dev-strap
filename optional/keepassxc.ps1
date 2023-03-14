if (choco list keepassxc -l | Select-String -pattern "1 packages installed." -quiet)
{    
    Write-Host -ForegroundColor Yellow "KeePassXC already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing KeePassXC"

    choco install -y keepassxc
    refreshenv
}

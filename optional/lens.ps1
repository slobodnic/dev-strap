if (choco list lens -l | Select-String -pattern "1 packages installed." -quiet)
{    
    Write-Host -ForegroundColor Yellow "Lens already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing Lens"

    choco install -y lens
    refreshenv
}

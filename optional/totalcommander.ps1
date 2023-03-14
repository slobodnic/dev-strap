Write-Host -ForegroundColor Green "Installing Total Commander"

if (choco list totalcommander -l | Select-String -pattern "1 packages installed." -quiet){
    Write-Host -ForegroundColor Yellow "Total Commander already install... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing Total Commander"
    choco install -y totalcommander
    refreshenv
}

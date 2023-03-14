if (Get-Command "lens" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "Lens already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing Lens"

    choco install -y lens
    refreshenv
}

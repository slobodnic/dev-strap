if (Get-Command "helm" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "Helm already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing Helm"

    choco install -y kubernetes-helm
    refreshenv
}

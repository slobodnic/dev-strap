if (Get-Command "kubectl" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "kubernetes-cli already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing kubernetes-cli"

    choco install -y kubernetes-cli
    refreshenv
}
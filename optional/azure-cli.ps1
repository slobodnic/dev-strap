if (Get-Command "az" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "Azure cli already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing Azure cli"

    choco install -y azure-cli
    refreshenv
}

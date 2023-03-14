if (Get-Command "docker" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "Docker already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing Docker"

    choco install -y docker-desktop
    refreshenv
}

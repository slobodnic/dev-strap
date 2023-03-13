if (Get-Command "git" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "Git already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing git"

    choco install -y git
    refreshenv
}

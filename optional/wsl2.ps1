if (Get-Command "wsl" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "wsl already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing wsl"

    choco install -y wsl2
    refreshenv
}

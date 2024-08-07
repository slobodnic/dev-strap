if (Get-Command "git-secrets" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "git secrets already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing git secrets"

    $binPath = ".\bin"
    New-Item -Path $binPath -ItemType Directory | Out-Null
    Set-Location $binPath

    Invoke-WebRequest -uri https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets -OutFile git-secrets
    Invoke-WebRequest -uri https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets.1 -OutFile git-secrets.1
    Invoke-WebRequest -uri https://raw.githubusercontent.com/awslabs/git-secrets/master/install.ps1 -OutFile install.ps1

   .\install.ps1

   Set-Location ".."
   Remove-Item $binPath -Force -Recurse
}
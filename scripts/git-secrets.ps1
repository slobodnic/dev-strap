if (Get-Command "git-secrets" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "git secrets already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing git secrets"

   Invoke-WebRequest -uri https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets -OutFile git-secrets
   Invoke-WebRequest -uri https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets.1 -OutFile git-secrets.1

   Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/awslabs/git-secrets/master/install.ps1'))

   del git-secrets*
}
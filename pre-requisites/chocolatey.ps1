if (Get-Command "chocolatey" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "Chocolatey already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing Chocolatey"

    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/api/v2//ChocolateyInstall.ps1'))
}

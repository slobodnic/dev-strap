Param([string]$SDKVersion = "6")
$sdk = "Microsoft.DotNet.SDK.$SDKVersion"
$runtime = "Microsoft.DotNet.Runtime.$SDKVersion"
#Invoke-WebRequest -uri https://dot.net/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1
#& ./dotnet-install.ps1 -Channel $SDKVersion
#Remove-Item ./dotnet-install.ps1 -Force

# Run a separate PowerShell process because the script calls exit, so it will end the current PowerShell session.

if (Get-Command "dotnet" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "dotnet already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing dotnet"

    winget install $runtime --silent
}

if (dotnet --list-sdks | Select-String -pattern $SDKVersion -quiet) {
    Write-Host -ForegroundColor Yellow "dotnet SDK $SDKVersion already install... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing dotnet SDK $SDKVersion"
    winget install $sdk --silent
}
Param([string]$SDKVersion = "6")
$sdk = "Microsoft.DotNet.SDK.$SDKVersion"
$runtime = "Microsoft.DotNet.Runtime.$SDKVersion"
#Invoke-WebRequest -uri https://dot.net/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1
#& ./dotnet-install.ps1 -Channel $SDKVersion
#Remove-Item ./dotnet-install.ps1 -Force

# Run a separate PowerShell process because the script calls exit, so it will end the current PowerShell session.
winget install $sdk --silent
winget install $runtime --silent
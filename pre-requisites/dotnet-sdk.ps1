Param([string]$SDKVersion = "6.0")

Invoke-WebRequest -uri https://dot.net/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1
& ./dotnet-install.ps1 -Channel $SDKVersion
Remove-Item ./dotnet-install.ps1 -Force
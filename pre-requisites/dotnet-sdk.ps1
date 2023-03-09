Param([string]$SDKVersion = "6.0")

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://dot.net/v1/dotnet-install.ps1')) -Chanel $SDKVersion
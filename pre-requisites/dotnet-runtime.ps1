Param([string]$SDKVersion = "6.0.14")

if (Get-Command "dotnet" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "dotnet already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing dotnet"

    choco install -y dotnet-6.0-runtime
    refreshenv
}
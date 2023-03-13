Param([string]$SDKVersion = "6.0.14")
# Run a separate PowerShell process because the script calls exit, so it will end the current PowerShell session.

if (Get-Command "dotnet" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "dotnet already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing dotnet"

    # winget install $runtime --silent
    choco install -y dotnet-6.0-runtime
    refreshenv
}
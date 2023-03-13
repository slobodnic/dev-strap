Param([string]$SDKVersion = "6.0.14")

if (dotnet --list-sdks | Select-String -pattern $SDKVersion -quiet) {
    Write-Host -ForegroundColor Yellow "dotnet SDK $SDKVersion already install... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing dotnet SDK $SDKVersion"
    choco install -y dotnet-6.0-sdk
}
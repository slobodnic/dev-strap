if (Get-Command "nuget" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "NuGet provider already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing NuGet provider"

    Install-PackageProvider -Name NuGet
}
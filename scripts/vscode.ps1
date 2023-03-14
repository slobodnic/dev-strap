#$channel = 'stable'
#$platform = 'win32-x64-user' 
#$SourceURL = "https://code.visualstudio.com/sha/download?build=$channel&os=$platform";
#$Installer = $env:TEMP + "\vscode.exe"; 

if (Get-Command "code" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "VSCode already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing VSCode"

    choco install -y vscode
    refreshenv
}

Write-Host -ForegroundColor Green "Installing VSCode addons"

if (Test-Path -Path .\plugins.txt -PathType Leaf) {
    foreach($plugin in Get-Content .\plugins.txt) {
        code --install-extension $plugin
    }
}

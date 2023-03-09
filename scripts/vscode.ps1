$channel = 'stable'
$platform = 'win32-x64-user' 
$SourceURL = "https://code.visualstudio.com/sha/download?build=$channel&os=$platform";
$Installer = $env:TEMP + "\vscode.exe"; 

if (Get-Command "code" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "VSCode already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing VSCode"

    Invoke-WebRequest $SourceURL -OutFile $Installer;
    Start-Process -FilePath $Installer -Args "/verysilent /tasks=addcontextmenufiles,addcontextmenufolders,addtopath" -Wait; 
    Remove-Item $Installer;
}

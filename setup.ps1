Param([switch]$InstallOptional)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    Start-Process PowerShell.exe -WorkingDirectory $PWD -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))        
    exit
}

Write-Host -ForegroundColor Green "Downloading all required scripts..."
$currentFolder = $($PWD)
$scriptsPath = $env:TEMP + "\dev-strap"
$prerequisitesPath = $scriptsPath+ "\dev-strap-main\pre-requisites"
New-Item -Path $scriptsPath -ItemType Directory | Out-Null
Set-Location $scriptsPath
Invoke-WebRequest -uri https://github.com/slobodnic/dev-strap/archive/refs/heads/main.zip -OutFile scripts.zip
Expand-Archive scripts.zip -DestinationPath .

'running with full privileges'
Write-Host -ForegroundColor Green "Installing pre-requisites" 
# The pre-requisit scripts are in order in which they need to install

Set-Location $prerequisitesPath
# & $prerequisitesPath\winget.ps1
& .\chocolatey.ps1; 
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv;
& .\dotnet-runtime.ps1;
& .\dotnet-sdk.ps1;
& .\git.ps1;
& .\nuget.ps1;
& .\python.ps1;

Write-Host -ForegroundColor Green "Installing the tools" 

Set-Location $scriptsPath'\dev-strap-main\scripts'
Get-ChildItem -Filter '*.ps1' $scriptsPath'\dev-strap-main\scripts' | ForEach-Object {
    & $_.FullName
}

if ($InstallOptional)
{
    Write-Host -ForegroundColor Green "Installing optional tools" 
    Set-Location $scriptsPath'\dev-strap-main\optional'
    Get-ChildItem -Filter '*.ps1' $scriptsPath'\dev-strap-main\optional' | ForEach-Object {
        & $_.FullName
    }
}

Set-Location $currentFolder
Remove-Item $env:TEMP\dev-strap\ -Force -Recurse
# stop-process -Id $PID
# logoff.exe
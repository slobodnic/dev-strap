Param (
    [Parameter(Position=0)]
    [switch]
    $InstallOptional,

    [Parameter()]
    [switch]
    $Online
)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

$currentFolder = $PWD
if (-NOT $Online -AND $myinvocation.MyCommand.Definition -like "*http*") {
    "Need to override online"
    $Online = $true;
}

if ((Test-Admin) -eq $false)  {
    $cmd = $myinvocation.MyCommand.Path 
    if ($InstallOptional) {
        $cmd += " -InstallOptional"
    } 
    if ($Online) {
        $cmd += " -Online"
    }

    Start-Process PowerShell.exe -WorkingDirectory $PWD -Verb RunAs -ArgumentList `
        ('-noprofile -noexit -Command ' + $cmd)
    exit
}

if ($myinvocation.MyCommand.Path) {
    $scriptsPath = Split-Path -parent $myinvocation.MyCommand.Path
} else {
    $scriptsPath = $env:TEMP
}
$prerequisitesPath = Join-Path $scriptsPath -ChildPath pre-requisites

if ($Online) {
    Write-Host -ForegroundColor Green "Downloading all required scripts..."
    $scriptsPath = Join-Path $env:TEMP -ChildPath dev-strap
    New-Item -Path $scriptsPath -ItemType Directory | Out-Null
    Set-Location $scriptsPath
    $pwd
    Invoke-WebRequest -uri https://github.com/slobodnic/dev-strap/archive/refs/heads/main.zip -OutFile scripts.zip
    Expand-Archive scripts.zip -DestinationPath $scriptsPath
    $scriptsPath = Join-Path $scriptsPath -ChildPath dev-strap-main
    $prerequisitesPath = Join-Path $scriptsPath -ChildPath pre-requisites
} else {
    Write-Host -ForegroundColor Green "Installing from local scripts..."
}

Write-Host -ForegroundColor Green "Installing pre-requisites" 
# The pre-requisit scripts are in order in which they need to install

& .\install.ps1 $prerequisitesPath

Write-Host -ForegroundColor Green "Installing the tools" 
& .\install.ps1 $scriptsPath'\required'

if ($InstallOptional)
{
    Write-Host -ForegroundColor Green "Installing optional tools" 
    & .\install.ps1 $scriptsPath'\optional'
}

Write-Host -ForegroundColor Green "Making sure all packages installed with chocolatey are the latest..." 
choco upgrade all

Set-Location $currentFolder
if ($Online) {
    Remove-Item $env:TEMP\dev-strap\ -Force -Recurse
}
# stop-process -Id $PID
# logoff.exe
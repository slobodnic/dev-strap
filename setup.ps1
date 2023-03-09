param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process pwsh.exe -WorkingDirectory $PWD -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))        
    }
    exit
}

Write-Host -ForegroundColor Green "Downloading all required scripts..."
mkdir dev-strap
Set-Location dev-strap
Invoke-WebRequest -uri https://dev.azure.com/hrblock/0470b46e-1f42-4fdf-b4aa-9b392089b0bc/_apis/git/repositories/fbb861e6-ede1-4166-8373-068dd14278d7/items?path=/&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true -OutFile scripts.zip

'running with full privileges'
Write-Host -ForegroundColor Green "Installing pre-requisites" 
# The pre-requisit scripts are in order in which they need to install

.\pre-requisites\dotnet.ps1
.\pre-requisites\chocolatey.ps1
.\pre-requisites\chocolatey.ps1
.\pre-requisites\python.ps1

Write-Host -ForegroundColor Green "Installing the tools" 

Get-ChildItem -Filter '*.ps1' '.\scripts' | ForEach-Object {
  & $_.FullName
}

# stop-process -Id $PID
# logoff.exe
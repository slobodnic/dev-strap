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
Invoke-WebRequest -uri https://github.com/slobodnic/dev-strap/archive/refs/heads/main.zip -OutFile scripts.zip
Expand-Archive scripts.zip -DestinationPath .

'running with full privileges'
Write-Host -ForegroundColor Green "Installing pre-requisites" 
# The pre-requisit scripts are in order in which they need to install

.\dev-strap-main\pre-requisites\dotnet.ps1
.\dev-strap-main\pre-requisites\chocolatey.ps1
.\dev-strap-main\pre-requisites\chocolatey.ps1
.\dev-strap-main\pre-requisites\python.ps1

Write-Host -ForegroundColor Green "Installing the tools" 

Get-ChildItem -Filter '*.ps1' '.\dev-strap-main\scripts' | ForEach-Object {
  & $_.FullName
}

# stop-process -Id $PID
# logoff.exe
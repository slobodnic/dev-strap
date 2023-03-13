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

# & $prerequisitesPath\winget.ps1
& $prerequisitesPath\chocolatey.ps1; 
& $prerequisitesPath\dotnet-runtime.ps1; 
& $prerequisitesPath\dotnet-sdk.ps1;
& $prerequisitesPath\git.ps1;
& $prerequisitesPath\nuget.ps1;
& $prerequisitesPath\python.ps1;

Write-Host -ForegroundColor Green "Installing the tools" 

Get-ChildItem -Filter '*.ps1' $scriptsPath'\dev-strap-main\scripts' | ForEach-Object {
    & $_.FullName
}

Set-Location $currentFolder
Remove-Item $env:TEMP\dev-strap\ -Force -Recurse
# stop-process -Id $PID
# logoff.exe
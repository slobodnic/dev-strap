Param (
    [Parameter(Position = 0)]
    [string]
    $Path = "."
)

Set-Location $Path
if (Test-Path -Path .\packages.json -PathType Leaf) {
    $json = Get-Content packages.json -Raw | ConvertFrom-Json;

    ForEach ($p in $json) {
    $package = $p.package;
        if ($package -eq $null) {
            $package = $p.name;
        }

        $name = $p.name;
        $version = $p.version;
        $postInstallScript = $p.postInstallScript;
        $type = $p.type;

        if ($type -eq "script") {
            Write-Host -ForegroundColor Gray "Executing script "$p.script;
            $script = $p.script;
            & .\$script;
        } elseif ($type -eq "pip") {
            if (pip list | Select-String -pattern $package) {
                Write-Host -ForegroundColor Yellow "$name already installed... skipping" 
            } else {
                Write-Host -ForegroundColor Green "Installing $name"
                pip install $package
            }
        }
        else {
            if (choco list $package --local --by-id-only | Select-String -pattern "0 packages installed." -quiet) {
                if ($version -eq $null) {
                    Write-Host -ForegroundColor Green "Installing $name"

                    choco install -y $package
                    Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"
                }
                else {
                    Write-Host -ForegroundColor Green "Installing $name version $version"

                    choco install -y $package --version $version
                    Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"
                }

                if ($postInstallScript) {
                    Write-Host -ForegroundColor Green "Executing post installation script"
                    & .\$postInstallScript;
                }    
            }
            else {    
                Write-Host -ForegroundColor Yellow "$package already exists... skipping" 
            }
        }
    }
}
else {
    Write-Host -ForegroundColor Yellow "Package.json file does not exists."
}
Set-Location "..";
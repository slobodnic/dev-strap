Param (
    [Parameter(Position = 0)]
    [string]
    $Path = "."
)

Set-Location $Path
if (Test-Path -Path .\packages.json -PathType Leaf) {
    Get-Content packages.json | 
    ConvertFrom-Json | 
    ForEach-Object { 
        $package = $_.package;
        if ($package -eq $null) {
            $package = $_.name;
        }

        $name = $_.name;
        $version = $_.version;
        $postInstallScript = $_.postInstallScript;
        $type = $_.type;

        if ($type -eq "script") {
            $script = $_.script;
            & .\$script;
        } elseif ($type -eq "pip") {
            if (pip show $package | Select-String -pattern "not found" -quiet) {
                Write-Host -ForegroundColor Green "Installing $name"
                pip install $package
            } else {
                Write-Host -ForegroundColor Yellow "$name already install... skipping" 
            }
        }
        else {

            if (choco find Git --local --by-id-only | Select-String -pattern "0 packages installed." -quiet) {
                if ($version -eq $null) {
                    Write-Host -ForegroundColor Green "Installing $name"

                    choco install -y $package
                    refreshenv
                }
                else {
                    Write-Host -ForegroundColor Green "Installing $name version $version"

                    choco install -y $package --version $version
                    refreshenv
                }

                if ($postInstallScript) {
                    Write-Host -ForegroundColor Green "Executing post installation script"
                    & .\$postInstallScript;
                }    
            }
            else {    
                Write-Host -ForegroundColor Yellow "$name already exists... skipping" 
            }
        }
    }
}
else {
    Write-Host -ForegroundColor Yellow "Package.json file does not exists."
}
Set-Location "..";
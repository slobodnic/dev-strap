Write-Host -ForegroundColor Green "Installing VSCode addons"

if (Test-Path -Path .\vs-plugins.txt -PathType Leaf) {
    $existingPlugins = code --list-extensions;

    foreach($plugin in Get-Content .\vs-plugins.txt) {
        if ($existingPlugins -contains $plugin) {
            Write-Host -ForegroundColor Yellow $plugin" already installed. Skipping ..."
        } else {
            Write-Host -ForegroundColor Green "Installing the following addons: "$plugin
            code --install-extension $plugin
        }
    }
} else {
    Write-Host -ForegroundColor Yellow "vs-plugins.txt file does not exists"
}

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

$plugins = "bierner.markdown-mermaid", `
            "ccimage.jsonviewer", `
            "dagra.jsonschemautils", `
            "hediet.vscode-drawio", `
            "marcoq.vscode-typescript-to-json-schema", `
            "Meezilla.json", `
            "mindaro-dev.file-downloader", `
            "mindaro.mindaro", `
            "mohsen1.prettify-json", `
            "ms-azuretools.vscode-docker", `
            "ms-dotnettools.csharp", `
            "ms-kubernetes-tools.vscode-kubernetes-tools", `
            "ms-python.python", `
            "ms-python.vscode-pylance", `
            "ms-toolsai.jupyter", `
            "ms-toolsai.jupyter-keymap", `
            "ms-toolsai.jupyter-renderers", `
            "ms-toolsai.vscode-jupyter-cell-tags", `
            "ms-toolsai.vscode-jupyter-slideshow", `
            "ms-vscode-remote.remote-containers", `
            "nickdemayo.vscode-json-editor", `
            "oliversturm.fix-json", `
            "redhat.vscode-yaml", `
            "streetsidesoftware.code-spell-checker", `
            "tomoyukim.vscode-mermaid-editor"


foreach ($plugin in $plugins) {
    code --install-extension $plugin
}


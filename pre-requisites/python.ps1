if (Get-Command "pip" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "Python already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing python"

    choco install -y python
    refreshenv
}

Write-Host -ForegroundColor Green "Upgrading pip" 
python.exe -m pip install --upgrade pip
refreshenv

pip list
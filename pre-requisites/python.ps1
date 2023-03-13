if (Get-Command "pip" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "Python already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing python"

    choco inst python
    refreshenv
    #del .\python-setup.exe
}

Write-Host -ForegroundColor Green "Upgrading pip" 
python.exe -m pip install --upgrade pip
refreshenv

pip list
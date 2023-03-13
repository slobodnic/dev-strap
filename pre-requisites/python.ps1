if (Get-Command "pip" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "Python already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing python"

    Invoke-WebRequest -uri https://www.python.org/ftp/python/3.11.2/python-3.11.2-amd64.exe -OutFile python-setup.exe
    .\python-setup.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    #del .\python-setup.exe
}

Write-Host -ForegroundColor Green "Upgrading pip" 
python.exe -m pip install --upgrade pip

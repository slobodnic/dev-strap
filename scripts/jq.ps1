if (Get-Command "jq" -errorAction SilentlyContinue)
{    
    Write-Host -ForegroundColor Yellow "jq already exists... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing jq"

   cinst -y jq
}
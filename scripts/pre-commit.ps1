if (pip list | Select-String -pattern "pre-commit" -quiet) {
    Write-Host -ForegroundColor Yellow "Pre-commit already install... skipping" 
} else {
    Write-Host -ForegroundColor Green "Installing pre-commit"
    pip install pre-commit       
}

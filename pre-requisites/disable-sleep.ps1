Write-Host -ForegroundColor Green "Disabling sleep mode when plugged in ..."
powercfg -change -standby-timeout-ac 0
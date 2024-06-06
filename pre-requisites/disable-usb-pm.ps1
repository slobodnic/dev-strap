function Disable-USBPowerManagement ($hubs, $powerMgmt) {
     foreach ($p in $powerMgmt) {
          #Write-Host -ForegroundColor Gray "Checking USB Power Management for "$p
          $IN = $p.InstanceName.ToUpper()

          foreach ($h in $hubs) {
               $PNPDI = $h.PNPDeviceID
               if ($IN -like "*$PNPDI*") {
                    if ($p.enable -eq $True) {
                         Write-Host -ForegroundColor Green "Disabling USB Power Management for $PNPDI -" $h.Description
                         $p.enable = $False
                         $p.psbase.put()
                    }
               }
          }
     }
}

$hubs = Get-WmiObject Win32_USBHub
$powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
Disable-USBPowerManagement $hubs $powerMgmt

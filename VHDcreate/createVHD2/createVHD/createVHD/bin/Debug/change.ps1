[System.String]$path_EMDMgmt = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\EMDMgmt"

Get-ChildItem $path_EMDMgmt -Recurse | Where {Get-ItemProperty -Path $_.PSPath -Name DeviceStatus -EA SilentlyContinue} | Foreach { Set-ItemProperty -Name DeviceStatus -Path $_.PSPath -Value 1 }
Get-ChildItem $path_EMDMgmt -Recurse | Where {Get-ItemProperty -Path $_.PSPath -Name CacheSizeInMB -EA SilentlyContinue} | Foreach { Set-ItemProperty -Name CacheSizeInMB -Path $_.PSPath -Value 1000 } 
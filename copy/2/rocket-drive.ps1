#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')

 [System.String]$temp = New-TemporaryFile
 [System.String]$path_folder = "$($evn:SyatemDrive)\RocketDrive"

 [System.String]$path_EMDMgmt = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\EMDMgmt"
 [System.String]$path_start_up = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
 [System.String]$path_disk_icon = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\R\DefaultIcon"
 [System.String]$path_icon = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\R"

 [System.String]$create_vhd = @"
@echo off   
SetLocal EnableExtensions
call :Invoke_UAC %*

set vdisk=c:\RocketDrive\RocketDrive.vhd

(
 echo create vdisk file="%vdisk%" maximum=5000 type=expandable
 echo select vdisk file="%vdisk%"
 echo attach vdisk
 echo create partition primary 
 echo format fs=NTFS label=RocketDrive quick
 echo assign letter=R
) | diskpart

Exit

:Invoke_UAC :: Затребование диалога UAC повышения прав
  ver |>nul find "6." && if "%1"=="" (
    Echo new ActiveXObject^('Shell.Application'^).ShellExecute ^(WScript.Arguments^(0^),'UAC','','runas',1^);>"%~dp0Invoke_UAC.js"
    cscript.exe //nologo //e:jscript "%~dp0Invoke_UAC.js" "%~f0"& Exit
  ) else (>nul del "%~dp0Invoke_UAC.js"& chdir /d "%~dp0")       
"@

 [System.String]$delete_vhd = @"
@echo off   
SetLocal EnableExtensions
call :Invoke_UAC %*

set vdisk=c:\RocketDrive\RocketDrive.vhd

(

 echo select vdisk file="%vdisk%"
 echo detach vdisk

) | diskpart

Exit

:Invoke_UAC :: Затребование диалога UAC повышения прав
  ver |>nul find "6." && if "%1"=="" (
    Echo new ActiveXObject^('Shell.Application'^).ShellExecute ^(WScript.Arguments^(0^),'UAC','','runas',1^);>"%~dp0Invoke_UAC.js"
    cscript.exe //nologo //e:jscript "%~dp0Invoke_UAC.js" "%~f0"& Exit
  ) else (>nul del "%~dp0Invoke_UAC.js"& chdir /d "%~dp0")       
"@

 [string]$reset_vhd = @"
    
"@
   
#function message
function message([System.String]$text) {
   [System.Windows.MessageBox]::Show($text, "RocketDrive")
}

#function Test-Path
function test_path($path) { Test-Path -Path $path }

#function Get-ChildItem "Search in reg"
function get_child_item ([System.String]$path, [System.String]$name, $value ) {
      Get-ChildItem $path -Recurse | Where {Get-ItemProperty -Path $_.PSPath -Name $name -EA SilentlyContinue} | Foreach {
      Set-ItemProperty -Name $name -Path $_.PSPath -Value $value
   }
}

#function download icon and some exe files
function download_res {
    try {
        if(test_path($path_folder) -eq $true) {
            #download icon from github
            [System.Net.ServicePointManager]::SecurityProtocol = @("Tls12","Tls11","Tls","Ssl3")
            Invoke-WebRequest -Uri "https://rocketdriveee.github.io/resurse/RocketDrive.ico" -OutFile "$($path_folder)\RocketDrive.ico"
            attrib +h "$($path_folder)\RocketDrive.ico"

            #download create_rocket_drive.exe from github
            Invoke-WebRequest -Uri "https://rocketdriveee.github.io/resurse/ROCKET_1/1/create_rocket_drive.exe" -OutFile "$($path_folder)\create_rocket_drive.exe"
            attrib +h "$($path_folder)\create_rocket_drive.exe"  

            #download delete_rocket_drive.exe from github
            Invoke-WebRequest -Uri "https://rocketdriveee.github.io/resurse/ROCKET_1/1/delete_rocket_drive.exe" -OutFile "$($path_folder)\delete_rocket_drive.exe"
            attrib +h "$($path_folder)\delete_rocket_drive.exe"
        }
    }
    catch {
       message($Error[0].Exception)
    }
}

#function add-icon
function add_icon {

 [string]$desktop_ini = @"
    [.ShellClassInfo]
    IconResource=C:\RocketDrive\RocketDrive.ico
"@

    try {
       #download icon from github
       [System.Net.ServicePointManager]::SecurityProtocol = @("Tls12","Tls11","Tls","Ssl3")
       Invoke-WebRequest -Uri "https://rocketdriveee.github.io/resurse/RocketDrive.ico" -OutFile "$($path_folder)\RocketDrive.ico"
       attrib +h "$($path_folder)\RocketDrive.ico"
    }
    catch {
       message($Error[0].Exception)   
    }

    try{
        if(test_path($path_folder) -eq $true) {
          New-Item -Path $path_folder -ItemType File -Name "desktop.ini" -Value $desktop_ini
          attrib +h "$($path_folder)\desktop.ini"
          attrib +r $path_folder 
        }
    }
    catch {
       message($Error[0].Exception)
    }
}

#function create-rocket-drive
function create_rocket_drive {
   try {
      if(test_path("$($path_folder)\RocketDrive.vhd") -eq $true) {
          message("RocketDrive is allready instaled!")
          break
      }
      Remove-Item -Path $path_EMDMgmt -Recurse -Force
      New-Item -Path $path_folder -Name "RocketDrive" -ItemType Directory -Force
    . download_res
      #start .exe 'create vhd'
      powershell -c "$($path_folder)\create_rocket_drive.exe" -weit
      if(test_path($path_EMDMgmt) -eq $true) {
          Get-ChildItem $path_EMDMgmt -Recurse | Where {Get-ItemProperty -Path $_.PSPath -Name StatusDevice -EA SilentlyContinue} | Foreach { Set-ItemProperty -Name StatusDevice -Path $_.PSPath -Value 2 }
          Get-ChildItem $path_EMDMgmt -Recurse | Where {Get-ItemProperty -Path $_.PSPath -Name CacheSizeInMB -EA SilentlyContinue} | Foreach { Set-ItemProperty -Name CacheSizeInMB -Path $_.PSPath -Value 100 } 
      }
      New-Item -Path $path_start_up -Name "RocketDrive" -Value "$($path_folder)\RocketDrive.vhd"
       
   }
   catch {
      message($Error[0].Exception)
   }
}

#. create_rocket_drive

#function delete-rocket-drive
function delete_rocket_drive {
    try {
       if(test_path("$($path_folder)\RocketDrive.vhd") -eq $true) {
            message("Done")
       }
       else {
            message("RocketDrive not install")
       }
    }
    catch {
        message($Error[0].Exception)
    }
}

#. delete_rocket_drive

#function reset-rocket-drive  
function reset_rocket_drive {
    
}

#create-rocket-drive
function create_vhd {

    try {
        if(test_path("$($path_folder)\RocketDrive.vhd") -eq $true) {
           message("RocketDrive allready exist!")
           break           
        } 
        else {
            
           $get_service = Get-Service -Name SysMain
           if($get_service.Status -eq "Stopped") {
               Start-Service -Name SysMain
           }

           if(test_path($path_EMDMgmt) -eq $true) {
               Remove-Item -Path $path_EMDMgmt -Recurse
           }

           New-Item -Path $path_folder -ItemType Directory -Force
           add_icon
           New-Item -Path "$($path_folder)\create_vhd.bat" -ItemType File -Value $create_vhd -Force

           Start-Process -FilePath "$($path_folder)\create_vhd.bat" -WindowStyle Hidden -Verb RunAs -Wait

           Remove-Item -Path "$($path_folder)\create_vhd.bat" -Recurse

           $device_Status_value = 2
           $chache_size_mb = 200

           get_child_item ($path_EMDMgmt, "DeviceStatus", $device_Status_value)
           get_child_item ($path_EMDMgmt, "CacheSizeInMB", $chache_size_mb)

           #Get-ChildItem $path_EMDMgmt -Recurse | Where { Get-ItemProperty -Path $_.PSPath -Name DeviceStatus -EA SilentlyContinue} | Foreach { Set-ItemProperty -Name DeviceStatus -Path $_.PSPath -Value 2 }
           #Get-ChildItem $path_EMDMgmt -Recurse | Where {Get-ItemProperty -Path $_.PSPath -Name CacheSizeInMB -EA SilentlyContinue} | Foreach { Set-ItemProperty -Name CacheSizeInMB -Path $_.PSPath -Value 300 }

           reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "RocketDrive" /d "$($path_folder)\RocketDrive.vhd" /f
           reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\R\DefaultIcon" /d "$($path_folder)\RocketDrive.ico" /f

        }
    }
    catch {
       message($Error[0].Exception)
    }

}

#. create_vhd

#delete-rocket-drive
function delete_vhd {   
  try {
        if(test_path("$($path_folder)\RocketDrive.vhd") -eq $true) {
           New-Item -Path "$($path_folder)\delete_vhd.bat" -ItemType File -Value $delete_vhd -Force
           Start-Process -FilePath "$($path_folder)\delete_vhd.bat" -WindowStyle Hidden -Verb RunAs -Wait
           Remove-Item -Path $path_folder -Recurse -Force
           if(test_path($path_icon) -eq $true) {
              Remove-Item -Path $path_icon -Recurse -Force
           }
           if(test_path($path_start_up) -eq $true) {
              Remove-Item -Path $path_start_up -Recurse -Force
              New-Item -Path $path_start_up
           }          
        }
        else {
           message("RocketDrive not instaled!")
        }
    }
    catch {
       message($Error[0].Exeption) 
    }
}

#. delete_vhd


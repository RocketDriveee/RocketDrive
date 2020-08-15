#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

#variable
function init {

 [System.String]$path_folder = "$($evn:SyatemDrive)\RocketDrive"

 [System.String]$path_EMDMgmt = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\EMDMgmt"
 [System.String]$path_start_up = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
 [System.String]$path_disk_icon = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\R\DefaultIcon"
 [System.String]$path_icon = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\R"

}
. init

#function message
function message([System.String]$text) {
   [System.Windows.MessageBox]::Show($text, "RocketDrive")
}

#function Test-Path
function test_path($path) { Test-Path -Path $path }

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

#delete-rocket-drive
function delete_vhd { 

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
           message("Done!")          
        }
        else {
           message("RocketDrive not instaled!")
        }
    }
    catch {
       message($Error[0].Exeption) 
    }
}

. delete_vhd
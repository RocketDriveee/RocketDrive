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

#create-rocket-drive
function create_vhd {

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

           #create RocketDrive
           New-Item -Path "$($path_folder)\create_vhd.bat" -ItemType File -Value $create_vhd -Force
           Start-Process -FilePath "$($path_folder)\create_vhd.bat" -WindowStyle Hidden -Verb RunAs -Wait
           Remove-Item -Path "$($path_folder)\create_vhd.bat" -Recurse

           #change value vdisk "R:\" in reg
           Get-ChildItem $path_EMDMgmt -Recurse | Where { Get-ItemProperty -Path $_.PSPath -Name DeviceStatus -EA SilentlyContinue} | Foreach { Set-ItemProperty -Name DeviceStatus -Path $_.PSPath -Value 2 }
           Get-ChildItem $path_EMDMgmt -Recurse | Where {Get-ItemProperty -Path $_.PSPath -Name CacheSizeInMB -EA SilentlyContinue} | Foreach { Set-ItemProperty -Name CacheSizeInMB -Path $_.PSPath -Value 300 }

           #add RocketDrive in startap folder
           reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "RocketDrive" /d "$($path_folder)\RocketDrive.vhd" /f

           #add icon RocketDrive in explorer vdisk "R:\"
           reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\R\DefaultIcon" /d "$($path_folder)\RocketDrive.ico" /f
           message("Done!")
        }
    }
    catch {
       message($Error[0].Exception)
    }

}

. create_vhd
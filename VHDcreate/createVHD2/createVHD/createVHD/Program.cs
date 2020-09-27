using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;
using Microsoft.Win32;
using System.Net.NetworkInformation;

namespace createVHD
{
    class Program
    {     
        static void Main(string[] args)
        {

            string start_up_folder = @"C:\Users\All Users\Microsoft\Windows\Start Menu\Programs\StartUp\RocketDrive.vhd";

            string path = @"C:\RocketDrive";
            string path_rocket_drive = @"C:\RocketDrive\RocketDrive.vhd";

            string create_bat = @"
@echo off   
reg delete 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\EMDMgmt';
(
 echo create vdisk file=c:\RocketDrive\RocketDrive.vhd maximum=5000 type=expandable
 echo select vdisk file =c:\RocketDrive\RocketDrive.vhd
 echo attach vdisk
 echo create partition primary
 echo format fs=NTFS label=RocketDrive quick
 echo assign letter=R
) | diskpart

Exit
";
            string path_create_bat = @"C:\RocketDrive\create.bat";

            string unmount_bat = @"
@echo off   

(
 echo select vdisk file =c:\RocketDrive\RocketDrive.vhd
 echo detach vdisk
) | diskpart

Exit
";
            string path_unmount_bat = @"C:\RocketDrive\unmount.bat";

            string path_del_EMD = @"E:\all\document\ProgectVisualStudio\C#\test\createVHD\createVHD\deleteEMD.bat";
            string path_change_reg = @"E:\all\document\ProgectVisualStudio\C#\test\createVHD\createVHD\change.ps1";



            if (!Directory.Exists(path))
            {
                try
                {                   
                    Process process = new Process();  // del path_EMDMegt
                    process.StartInfo.FileName = path_del_EMD;
                    process.StartInfo.CreateNoWindow = true;
                    process.StartInfo.UseShellExecute = false;
                    process.Start();
                    process.WaitForExit();

                    Directory.CreateDirectory(path); // Create directory

                    File.WriteAllText(path_create_bat, create_bat); // Create 'create.bat' file

                    Process process1 = new Process(); // Run 'create.bat' file
                    process1.StartInfo.FileName = path_create_bat;
                    process1.StartInfo.CreateNoWindow = true;
                    process1.StartInfo.UseShellExecute = false;
                    process1.Start();
                    process1.WaitForExit();

                                                                       
                    File.SetAttributes(path, FileAttributes.Hidden); 
                    File.SetAttributes(path_rocket_drive, FileAttributes.Hidden);

                    File.Delete(path_create_bat); // Delete 'create.bat' file

                    File.Copy(path_rocket_drive, start_up_folder, true); // Add RocketDrive in start_up folder
                  
                    RegistryKey vdiskIcon = Registry.LocalMachine;  // Add icon
                    RegistryKey reg = vdiskIcon.CreateSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\R\DefaultIcon");
                    reg.SetValue("", @"E:\all\document\ProgectVisualStudio\C#\test\createVHD\createVHD\RocketDrive.ico");

                    RegistryKey start_up = Registry.LocalMachine; 
                    RegistryKey reg1 = start_up.CreateSubKey(@"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run");
                    reg1.SetValue("RocketDrive", path_rocket_drive);


                    Process.Start("PowerShell", " -executionpolicy RemoteSigned -nologo -noninteractive -windowStyle hidden -File " + path_change_reg).WaitForExit();
                }

                catch (Exception e)
                {
                    MessageBox.Show(e.Message);
                }
            }
            else
            {
                try
                {
                    if (!Directory.Exists(@"R:\")) // if RocketDrive not mount
                    {   
                        Directory.Delete(path, true);  // Delete directory
                    }
                    else // if RocketDrive mount
                    {
                        File.WriteAllText(path_unmount_bat, unmount_bat);  // Create 'unmount_bat' file

                        Process proc1 = new Process(); // Run 'unmount_bat' file
                        proc1.StartInfo.FileName = path_unmount_bat;
                        proc1.StartInfo.CreateNoWindow = true;
                        proc1.StartInfo.UseShellExecute = false;                        
                        proc1.Start();
                        proc1.WaitForExit();

                        Directory.Delete(path, true); // Delete Directory
                        File.Delete(start_up_folder); // Delete RocketDrive in start_up folder


                        Registry.LocalMachine.DeleteSubKeyTree(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\R", true); // Delele icon

                        RegistryKey reg = Registry.LocalMachine;
                        RegistryKey regDell = reg.OpenSubKey(@"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run", true);                                       
                        regDell.DeleteValue("RocketDrive");
                        regDell.Close();
                       
                        MessageBox.Show("Done!", "RocketDrive");
                    }
                }
                catch(Exception e)
                {
                    MessageBox.Show(e.Message);
                }
            }
        }
    }
}

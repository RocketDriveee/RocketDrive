using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;
using Microsoft.Win32;

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

            // string changeValue_ps1 = @"";
            // string pathChangeValue_ps1 = @"";

            // string start_pathChangeValue_ps1 = @"";
            //string path_start_pathChangeValue_ps1 = @"";

            string path_EMDMgmt = @"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\EMDMgmt";


            if (!Directory.Exists(path))
            {
                try
                {
                    //Registry.LocalMachine.DeleteSubKey(@"SOFTWARE\Microsoft\Windows NT\CurrentVersion\EMDMgmt", true); ;
                   
                    Directory.CreateDirectory(path);
                        
                    File.WriteAllText(path_create_bat, create_bat);

                    Process proc = new Process();
                    proc.StartInfo.FileName = path_create_bat;
                    proc.StartInfo.CreateNoWindow = true;
                    proc.StartInfo.UseShellExecute = false;
                    proc.Start();
                    proc.WaitForExit();

                    File.SetAttributes(path, FileAttributes.Hidden);
                    File.SetAttributes(path_rocket_drive, FileAttributes.Hidden);

                    File.Delete(path_create_bat);

                    File.Copy(path_rocket_drive, start_up_folder, true);

                    RegistryKey vdiskIcon = Registry.LocalMachine;
                    RegistryKey reg = vdiskIcon.CreateSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\R\DefaultIcon");
                    reg.SetValue("", @"E:\all\document\ProgectVisualStudio\C#\test\createVHD\createVHD\RocketDrive.ico");

                    RegistryKey start_up = Registry.LocalMachine;
                    RegistryKey reg1 = start_up.CreateSubKey(@"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run");
                    reg1.SetValue("RocketDrive", path_rocket_drive);

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
                    if (!Directory.Exists(@"R:\"))
                    {
                        Directory.Delete(path, true);
                    }
                    else
                    {
                        File.WriteAllText(path_unmount_bat, unmount_bat);

                        Process proc1 = new Process();
                        proc1.StartInfo.FileName = path_unmount_bat;
                        proc1.StartInfo.CreateNoWindow = true;
                        proc1.StartInfo.UseShellExecute = false;                        
                        proc1.Start();
                        proc1.WaitForExit();

                        Directory.Delete(path, true);
                        File.Delete(start_up_folder);


                        Registry.LocalMachine.DeleteSubKeyTree(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\R", true);

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

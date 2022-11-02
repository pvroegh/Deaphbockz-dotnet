# DEAPHBOCKZ (Devbox) 
DeaphBockz is a set of Powershell scripts with which you can quickly setup 
a fully functioning .NET development environment in Windows🤘, but if 
you customize the various provisioning scripts, it can be any sort of 
environment you want. After installation is done, you can even 
add the created .vhdx (Virtual Hard Disk) file to your bootloader
and boot natively from this disk. Only the drive is virtual, the rest 
is all running natively, which means better performance. 

### Used software
- Convert-WindowsImage Powershell script to convert a Windows .iso to .vhdx.
  Source can be found here: https://github.com/x0nn/Convert-WindowsImage.

### Prerequisites
- A genuine Windows Installation Media (WIM) .iso file. Can be downloaded from Microsoft or my.visualstudio.com if you have a Visual Studio Subscription.
- A genuine Windows Product Key for the edition of Windows you want to install.
- A working Hyper-V installation (optional if you want to boot natively from the .vhdx).

### How to run:
- Just run this script as administrator in a Powershell console.
- After the installation and provisioning is done, you can start the VM
  from the created shortcut on the Desktop. When logging in, a Powershell
  script will be started automatically. This script is setting up your
  Powershell theme for Windows Terminal.

### How to add the created .vhdx to your PC's bootloader:
- Start cmd.exe as administrator (not Powershell!).
- Execute the following commands: 
  - `bcdedit /export backup-bootloader.dat` (this makes a backup of your current boot settings).
  - `bcdedit /copy {current} /d "<name to appear in boot menu>"` (copy the returned GUID to the clipboard).
  - `bcdedit /set {<paste the copied GUID here>} device vhd=[c:]\path\to\your\virtual-hard-disk.vhdx` (mind the square brackets!).
  - `bcdedit /set {<paste the copied GUID here>} osdevice vhd=[c:]\path\to\your\virtual-hard-disk.vhdx` (mind the square brackets!).
  - `bcdedit /set {<paste the copied GUID here>} detecthal on`
- To restore you original boot settings:
  - `bcdedit /import backup-bootloader.dat`

### Things to improve in the future:
- Validate VHD Size.
- Validate CPU Count.
- Validate Mem Size.
- Let the user select the Hyper-V switch from a list of available switches.
- Parameterize more variables in autounattend.xml (like language and keyboard settings);
- Automatically manipulate boot settings by adding option to boot natively from VHD.
- Fix error in powershell theme installation script (setting font in Windows Terminal).
- Log all output to a file so troubleshooting is easier.

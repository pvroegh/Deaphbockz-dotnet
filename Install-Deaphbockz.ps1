#Requires -RunAsAdministrator

Write-Host @'
 _____                   _     _                _         
|  __ \                 | |   | |              | |        
| |  | | ___  __ _ _ __ | |__ | |__   ___   ___| | __ ____
| |  | |/ _ \/ _` | '_ \| '_ \| '_ \ / _ \ / __| |/ /|_  /
| |__| |  __/ (_| | |_) | | | | |_) | (_) | (__|   <  / / 
|_____/ \___|\__,_| .__/|_| |_|_.__/ \___/ \___|_|\_\/___|
                  | |                                     
                  |_|                                     
'@ -ForegroundColor Yellow

# Load dependencies
. .\Dependencies\Convert-WindowsImage.ps1
. .\Dependencies\Test-VMAccess.ps1
. .\Dependencies\Get-WindowsEdition.ps1
. .\Dependencies\Get-InputFromPrompt.ps1
. .\Dependencies\Test-HyperVIsInstalled.ps1
. .\Dependencies\Get-AutoPlayEnabled.ps1
. .\Dependencies\Set-AutoPlayEnabled.ps1
. .\Dependencies\Add-Shortcut.ps1
. .\Dependencies\Set-VariablesInAutoUnattendFile.ps1

# Little helper function to reboot a VM and wait for it to come online.
function Restart-VMAndWaitForAccess
(
    [string]$VMName,
    [System.Management.Automation.PSCredential]$Credential
)
{
    Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock { Restart-Computer -Force }
    Start-Sleep -Seconds 15
    $Result = Test-VMAccess -VMName $VMName -Credential $Credential

    return $Result
}

# Check if Hyper-V is installed, otherwise just exit.
if (!(Test-HyperVIsInstalled)) {
    Write-Error -Message "Hyper-V isn't installed. Exiting." -ErrorAction Stop
}

# Remember the user's autoplay setting and set autoplay off
# to prevent autoplay popups during mounting of the image.
$OriginalAutoPlayEnabled = Get-AutoPlayEnabled
Set-AutoPlayEnabled -Enabled $false

try {
    # Gather input from the user to determime the variables.
    $SelectedVMName = Get-InputFromPrompt -Prompt "VM Name" -DefaultValue "DEAPHBOCKZ-VM"
    $SelectedComputerName = Get-InputFromPrompt -Prompt "Computer Name" -DefaultValue "DEAPHBOCKZ-PC"
    $SelectedWindowsKey = Get-InputFromPrompt -Prompt "Windows Key (press ENTER for none)"
    $DefaultSwitch = (Get-VMSwitch | Select-Object -First 1).Name
    $SelectedIsoFile = Get-InputFromPrompt -Prompt "Windows .iso Path" -IsMandatory -DefaultValue ".\Iso\Windows11.iso"

    $SelectedUsername = Get-InputFromPrompt -Prompt "VM Admin Username" -DefaultValue "Admin"
    $SelectedPassword = Get-InputFromPrompt -Prompt "VM Admin Password" -IsMandatory -IsSecureString
    $SelectedVHDSize = Get-InputFromPrompt -Prompt "Virtual Hard Disk Size in GB" -DefaultValue "100" 
    $SelectedCPUCount = Get-InputFromPrompt -Prompt "VM number of CPU's" -DefaultValue "4"
    $SelectedMaxMemorySize = Get-InputFromPrompt -Prompt "VM maximum memory size in GB" -DefaultValue "8"
    $SelectedSwitch = Get-InputFromPrompt -Prompt "Hyper-V Switch" -DefaultValue $DefaultSwitch
    $SelectedEdition = Get-WindowsEdition -IsoImageFilePath $SelectedIsoFile

    # Start timer to time the whole operation
    $Stopwatch =  [system.diagnostics.stopwatch]::StartNew()

    # Check if the supplied .iso path exists.
    if (!(Test-Path -Path $SelectedIsoFile)) {
        Write-Error -Message "The specified Windows .iso path doesn't exist. Please specify a valid path. Exiting."
    }

    # Write variables to autounattend.xml file
    New-Item -ItemType Directory -Force -Path ".\Vm\$SelectedVMName"
    $AutoUnattendFileFullname = ".\Vm\$SelectedVMName\autounattend.xml"
    Copy-Item -Path ".\Provisioning\autounattend.xml" -Destination $AutoUnattendFileFullname
    Set-VariablesInAutoUnattendFile -AutoUnattendFileFullname $AutoUnattendFileFullname -Username $SelectedUsername -Password $SelectedPassword -ComputerName $SelectedComputerName -WindowsKey $SelectedWindowsKey

    # Create the Virtual Hard Disk from the Windows Image Media file and
    # bootstrap it with the autounattend.xml file for unattended installation.
    Write-Host "Converting the supplied Windows Image Media to a Virtual Hard Disk..." -ForegroundColor Blue
    $VhdxFullname = ".\Vm\$SelectedVMName\$SelectedVMName.vhdx"
    Convert-WindowsImage -SourcePath $SelectedIsoFile -VHDFormat "VHDX" -SizeBytes ([int]$SelectedVHDSize * 1GB) -IsFixed -Edition $SelectedEdition -DiskLayout "UEFI" -VHDPath $VhdxFullname -UnattendPath $AutoUnattendFileFullname -MergeFolder ".\Provisioning\MergeFolder"

    # Create the credential to use to access and provision the VM.
    $Credential = New-Object System.Management.Automation.PSCredential ($SelectedUsername, $SelectedPassword) 

    # Create and start the VM
    Write-Host "Creating and starting VM..." -ForegroundColor Blue
    $VMPath = ".\Vm\$SelectedVMName"
    New-VM -Name $SelectedVMName -MemoryStartupBytes 2GB -BootDevice VHD -VHDPath $VhdxFullname -Path $VMPath -Generation 2 -SwitchName $SelectedSwitch
    Set-VM -Name $SelectedVMName -ProcessorCount $SelectedCPUCount -CheckpointType Disabled
    Set-VMMemory -VMName $SelectedVMName -DynamicMemoryEnabled $true -MinimumBytes 2GB -MaximumBytes ([int]$SelectedMaxMemorySize * 1GB) -Priority 100
    Set-VMProcessor -VMName $SelectedVMName -ExposeVirtualizationExtensions $true
    Start-VM -Name $SelectedVMName

    # Wait for the VM to start and be accessible.
    Write-Host "Waiting for VM to start and be accessible..." -ForegroundColor Blue
    $CanStartPSDirectSession = Test-VMAccess -VMName $SelectedVMName -Credential $Credential
    
    if ($CanStartPSDirectSession) {
        Write-Host "VM is accessible, starting provisioning..." -ForegroundColor Blue
        Enable-VMIntegrationService -VMName $SelectedVMName -Name "Guest Service Interface"
        Invoke-Command -VMName $SelectedVMName -Credential $Credential -FilePath ".\Provisioning\pre-windowssettings.ps1"
        Invoke-Command -VMName $SelectedVMName -Credential $Credential -FilePath ".\Provisioning\install-tools.ps1"
        Invoke-Command -VMName $SelectedVMName -Credential $Credential -FilePath ".\Provisioning\install-windowsupdates.ps1"
        Invoke-Command -VMName $SelectedVMName -Credential $Credential -FilePath ".\Provisioning\post-windowssettings.ps1"
    
        Write-Host "Provisioning finished, restarting VM..." -ForegroundColor Blue
        Restart-VMAndWaitForAccess -VMName $SelectedVMName -Credential $Credential

        Write-Host "Creating shortcut to VM on the Desktop..." -ForegroundColor Blue
        $DesktopPath = [Environment]::GetFolderPath("Desktop")
        $ShortcutPath = "$DesktopPath\Connect to $SelectedVMName.lnk"
        Add-Shortcut -ShortcutPath $ShortcutPath -TargetPath "vmconnect.exe" -Arguments "localhost ""$SelectedVMName""" -RunAsAdministrator
    } else {
        Write-Host "The VM is not accessible; unable to provision. Exiting." -ForegroundColor Red
        Exit
    }

    $ElapsedSeconds = [math]::Round($Stopwatch.Elapsed.TotalSeconds,0)
    Write-Output "Elasped seconds: $ElapsedSeconds"
}
catch {
    $_
}
finally {
    # Restore user's autoplay setting
    Set-AutoPlayEnabled -Enabled $OriginalAutoPlayEnabled
}

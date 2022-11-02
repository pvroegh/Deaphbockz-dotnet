Write-Host "Installing Windows updates" -ForegroundColor Blue

Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force
Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -AddServiceFlag 7 -Confirm:$false
Get-WindowsUpdate -Install -ForceInstall -WindowsUpdate -AcceptAll -IgnoreReboot 
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
choco feature enable -n=allowGlobalConfirmation
refreshenv

# ---- Install WSL ----
wsl --install
wsl --update
refreshenv

# ---- Install local IIS ----
choco install IIS-WebServerRole --source windowsfeatures --limitoutput --no-progress
choco install NetFx4Extended-ASPNET45 --source windowsfeatures --limitoutput --no-progress
choco install IIS-NetFxExtensibility45 --source windowsfeatures --limitoutput --no-progress
choco install IIS-ISAPIExtensions --source windowsfeatures --limitoutput --no-progress
choco install IIS-ISAPIFilter --source windowsfeatures --limitoutput --no-progress
choco install IIS-ASPNET45 --source windowsfeatures --limitoutput --no-progress
choco install IIS-WebSockets --source windowsfeatures --limitoutput --no-progress
choco install IIS-HttpCompressionDynamic --source windowsfeatures --limitoutput --no-progress
choco install IIS-BasicAuthentication --source windowsfeatures --limitoutput --no-progress
choco install IIS-WindowsAuthentication --source windowsfeatures --limitoutput --no-progress
refreshenv

# ---- Web Platform Installer ----
choco install webpi --limitoutput --no-progress
choco install UrlRewrite2 --source webpi --limitoutput --no-progress
choco install ARRv3_0 --source webpi --limitoutput --no-progress
refreshenv

# ---- Applications ----
choco install git --limitoutput --no-progress
choco install nuget.commandline --limitoutput --no-progress
choco install 7zip --limitoutput --no-progress
choco install googlechrome --limitoutput --no-progress
choco install notepadplusplus --limitoutput --no-progress
choco install vscode --limitoutput --no-progress
choco install azure-data-studio --limitoutput --no-progress
choco install putty.install --limitoutput --no-progress
choco install dotnet-sdk --limitoutput --no-progress
choco install dotnet-windowshosting --limitoutput --no-progress
choco install sql-server-2019 --limitoutput --no-progress
choco install sql-server-management-studio --limitoutput --no-progress
choco install docker-desktop --limitoutput --no-progress
choco install fiddler --limitoutput --no-progress
choco install wireshark --limitoutput --no-progress
choco install postman --limitoutput --no-progress
choco install microsoftazurestorageexplorer --limitoutput --no-progress
choco install microsoft-windows-terminal --limitoutput --no-progress
choco install powertoys --limitoutput --no-progress
choco install paint.net --limitoutput --no-progress
choco install drawio --limitoutput --no-progress
choco install nodejs-lts --limitoutput --no-progress
choco install nuget.commandline --limitoutput --no-progress
choco install python --limitoutput --no-progress
choco install winmerge --limitoutput --no-progress
choco install keepass --limitoutput --no-progress
choco install office365business --params "'/productid:O365BusinessRetail /exclude:Access Groove Lync Publisher /language:en-US /eula:TRUE'"  --limitoutput --no-progress
choco install firefox -packageParameters "l=en-US" --limitoutput --no-progress
refreshenv

# ---- Install Powershell theme ----
# The installation of the Powershell theme will be deferred to when the user
# interactively logs in for the first time on the VM. This is accomplished
# by using a Windows Scheduled Task which triggers when the user logs in
# interactively.
wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true
$ScheduledTaskAction = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-ExecutionPolicy Bypass -File c:\Assets\install-terminal-theme.ps1"
$ScheduledTaskTrigger = New-ScheduledTaskTrigger -AtLogOn
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName "Install Powershell Theme" -Action $ScheduledTaskAction -Trigger $ScheduledTaskTrigger -Settings $Settings -RunLevel Highest

# ---- Visual Studio 2022 ----
choco install visualstudio2022enterprise --limitoutput --no-progress
choco install visualstudio2022-workload-netweb --limitoutput --no-progress
choco install visualstudio2022-workload-manageddesktop --limitoutput --no-progress
choco install visualstudio2022-workload-azure --limitoutput --no-progress
choco install visualstudio2022-workload-data --limitoutput --no-progress
refreshenv

# .NET / Azure Tools
nuget sources Add -Name "NuGet" -Source https://api.nuget.org/v3/index.json
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
dotnet tool install --global dotnet-ef
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
choco install azure-cli --limitoutput --no-progress
choco install azure-functions-core-tools --limitoutput --no-progress
choco install bicep --limitoutput --no-progress

# ---- Visual Studio Code Extensions ----
code --install-extension ritwickdey.LiveServer
code --install-extension dbaeumer.vscode-eslint
code --install-extension stylelint.vscode-stylelint
code --install-extension Zignd.html-css-class-completion
code --install-extension sidthesloth.html5-boilerplate
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.csharp
code --install-extension formulahendry.dotnet-test-explorer
code --install-extension yzhang.markdown-all-in-one
code --install-extension DotJoshJohnson.xml
code --install-extension eamodio.gitlens
code --install-extension josefpihrt-vscode.roslynator
code --install-extension Fudge.auto-using
code --install-extension adrianwilczynski.namespace
code --install-extension PKief.material-icon-theme
code --install-extension GitHub.copilot
code --install-extension ms-vscode.powershell
code --install-extension editorconfig.editorconfig

choco feature disable -n=allowGlobalConfirmation
refreshenv

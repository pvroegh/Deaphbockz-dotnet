# Install the necessary components to 'pimp' up the powershell console.
# Assumptions:
# - Chocolatey is installed
# - Windows Terminal is installed
# - This script will be run by the "Install Powershell Theme" scheduled task.
#

# Only run when the user has logged in interactively. This will prevent the payload 
# of this script to be run if the user is logging in via a remote Powershell session.
if ([System.Environment]::UserInteractive) {
    Write-Host "Installing the necessary components to add themeing to your Windows Terminal / Powershell CLI." -ForegroundColor Blue
    Unregister-ScheduledTask -TaskName "Install Powershell Theme" -TaskPath "\" -Confirm:$False
    Set-ExecutionPolicy ByPass
    choco feature enable -n=allowGlobalConfirmation
    choco install oh-my-posh
    choco install poshgit
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/paradox.omp.json" -OutFile "c:\Assets\paradox.omp.json"
    refreshenv

    $Command = 'C:\Program Files (x86)\oh-my-posh\bin\oh-my-posh.exe'
    $Arg1 = "font"
    $Arg2 = "install"
    $Arg3 = '"FiraCode"'
    & $Command $Arg1 $Arg2 $Arg3

    # Start Windows Terminal to ensure that settings.json is created.
    $WindowsTerminalExePath = (Get-Command wt).Path
    $WindowsTerminalProcess = Start-Process $WindowsTerminalExePath -PassThru
    Start-Sleep -Seconds 5
    Stop-Process -InputObject $WindowsTerminalProcess

    # Alter the Windows Terminal's settings.json file to set the Meslo font.
    $Jsonfile = [Environment]::ExpandEnvironmentVariables(
        '%localappdata%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    )
    $JsonToAdd = @'
{
    "face": "FiraCode NFM"
}
'@
    $Json = Get-Content $Jsonfile | Out-String | ConvertFrom-Json
    $Json.profiles.defaults | Add-Member -Name "font" -Value (ConvertFrom-Json $JsonToAdd) -MemberType NoteProperty  
    $Json | ConvertTo-Json -Depth 100 | Set-Content $Jsonfile

    # Add oh-my-posh to the Powershell profile
    $TextToAddToPSProfile = @"
oh-my-posh --init --shell pwsh --config "C:\Assets\paradox.omp.json" | Invoke-Expression
"@
    Add-Content $PROFILE -Value $TextToAddToPSProfile
}
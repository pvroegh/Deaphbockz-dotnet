$ScriptPath = 'https://github.com/x0nn/Convert-WindowsImage/raw/main/Convert-WindowsImage.ps1'
$ScriptBody = (New-Object System.Net.WebClient).DownloadString($ScriptPath) 
Set-Variable -name CreateFunctionBody -value $ScriptBody -scope global
Invoke-Expression $CreateFunctionBody
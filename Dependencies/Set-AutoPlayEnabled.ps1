function Set-AutoPlayEnabled
(
    [Parameter(Mandatory=$true, HelpMessage="True for enabling autoplay, otherwise false.")]
    [bool]$Enabled
)
{
    if ($Enabled) {
        $Value = 0
    } else {
        $Value = 1
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value $Value
}
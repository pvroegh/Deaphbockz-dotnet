function Add-Shortcut
(
    [string]$ShortcutPath,
    [string]$TargetPath,
    [string]$Arguments,
    [switch]$RunAsAdministrator
)
{
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Arguments = $Arguments
    $Shortcut.Save()

    if ($RunAsAdministrator) {
        # Change the shortcut to run as administrator.
        $Bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
        $Bytes[0x15] = $Bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
        [System.IO.File]::WriteAllBytes($ShortcutPath, $bytes)
    }
}
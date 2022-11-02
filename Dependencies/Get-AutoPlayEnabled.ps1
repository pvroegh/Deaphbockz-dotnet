function Get-AutoPlayEnabled
{
    $Value = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay").DisableAutoplay
    if ($Value -eq 0) {
        return $true
    } else {
        return $false
    }
}
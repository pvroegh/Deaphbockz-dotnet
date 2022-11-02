Function Get-WindowsEdition
(
    [Parameter(Mandatory=$true, HelpMessage="The full path to the .ISO image file containing the Windows Image.")]
    [string]$IsoImageFilePath
)
{
    try {
        if (!(Test-Path -Path $IsoImageFilePath)) {
            Write-Error -Message "Invalid path: $IsoImageFilePath" -ErrorAction Stop
        }
        $MountResult = Mount-DiskImage -ImagePath (Resolve-Path $IsoImageFilePath) -PassThru
        $DriveLetter = ($MountResult | Get-Volume).DriveLetter
        
        $ImagePath = $DriveLetter + ":\sources\install.wim"
        if (!(Test-Path -Path $ImagePath)) {
            Write-Error -Message "The supplied image is not a valid Windows Installation Media." -ErrorAction Stop
        }

        $WinImages = Get-WindowsImage -ImagePath $ImagePath | Select-Object -Property ImageIndex, ImageName
        $EditionSelection = ($WinImages | Out-GridView -Title "Please select the edition to install" -OutputMode Single)

        if (!$EditionSelection) {
            Write-Error -Message "No edition selected by user." -ErrorAction Stop
        }
        
        return $EditionSelection.ImageIndex
    }
    finally {
        if ($MountResult) {
            Dismount-DiskImage -ImagePath $MountResult.ImagePath | Out-Null
        }
    }
} 
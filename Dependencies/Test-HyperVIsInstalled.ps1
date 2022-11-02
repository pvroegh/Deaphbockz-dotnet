function Test-HyperVIsInstalled
{
    $HyperV = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online

    if ($HyperV.State = "Enabled") {
        return $true
    } else {
        return $false
    }
}
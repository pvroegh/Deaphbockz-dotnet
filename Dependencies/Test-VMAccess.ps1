Function Test-VMAccess
(
    [Parameter(Mandatory=$true, HelpMessage="The name of the local Hyper-V VM.")] 
    [string]$VMName,
    [Parameter(Mandatory=$true, HelpMessage="The credentials for which to test a session.")] 
    [System.Management.Automation.PSCredential]$Credential,
    [Parameter(Mandatory=$false, HelpMessage="Timeout is seconds.")] 
    [int]$TimeoutInSeconds = 600,
    [Parameter(Mandatory=$false, HelpMessage="Wait time in seconds in between polls.")] 
    [int]$PollingWaitTimeInSeconds = 10
)
{
    $Timeout = New-TimeSpan -Seconds $TimeoutInSeconds
    $Stopwatch = [system.diagnostics.stopwatch]::StartNew()
    do
    {
        $VMInfo = Get-Vm $VMName

        if ($VMInfo.Heartbeat -eq "OkApplicationsUnknown") {
            $Session = New-PSSession -VMName $VMName -Credential $Credential -ErrorAction SilentlyContinue
            if ($Session) { Remove-PSSession -Session $Session; return $true }
        }
 
        if ($Stopwatch.Elapsed -gt $Timeout) { return $false }
        Start-Sleep -Seconds $PollingWaitTimeInSeconds
    }
    while ($true)

    return $false
}
function Set-VariablesInAutoUnattendFile
(
    [string]$AutoUnattendFileFullname,
    [string]$Username,
    [string]$Password,
    [string]$ComputerName,
    [string]$WindowsKey
)
{
    $XmlFilePath = Resolve-Path -Path $AutoUnattendFileFullname
    [xml]$Xml = Get-Content -Path $XmlFilePath

    $SpecializeNode = $Xml.unattend.settings | Where-Object { $_.pass -eq "specialize" }
    $ComponentNode = $SpecializeNode.component | Where-Object { $_.name -eq "Microsoft-Windows-Shell-Setup" }
    $ComponentNode.ComputerName = $ComputerName
    $ComponentNode.ProductKey = $WindowsKey

    $OobeSystemNode = $Xml.unattend.settings | Where-Object { $_.pass -eq "oobeSystem" }
    $ComponentNode = $OobeSystemNode.component | Where-Object { $_.name -eq "Microsoft-Windows-Shell-Setup" }
    $ComponentNode.AutoLogon.Password.Value = $Password
    $ComponentNode.AutoLogon.Username = $Username
    $ComponentNode.UserAccounts.LocalAccounts.LocalAccount.Password.Value = $Password
    $ComponentNode.UserAccounts.LocalAccounts.LocalAccount.DisplayName = $Username
    $ComponentNode.UserAccounts.LocalAccounts.LocalAccount.Name = $Username
    $ComponentNode.RegisteredOwner = $Username

    $Xml.Save($XmlFilePath)
}
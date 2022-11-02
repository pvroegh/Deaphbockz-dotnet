function Get-InputFromPrompt
(
    [Parameter(Mandatory=$true, HelpMessage="The prompt to show to the user.")]
    [string]$Prompt,
    [Parameter(Mandatory=$false, HelpMessage="The default value when a user doesn't supply an explicit value.")]
    [string]$DefaultValue,
    [Parameter(Mandatory=$false, HelpMessage="Swith to indicate if the input must be secure.")]
    [switch]$IsSecureString = $false,
    [Parameter(Mandatory=$false, HelpMessage="Swith to indicate if a value must be given.")]
    [switch]$IsMandatory = $false
)
{
    $PromptForMandatory = $false

    do
    { 
        if ($DefaultValue) {
            $CombinedPrompt = "$Prompt (press ENTER for default value: $DefaultValue)"
        } else {
            if (!$PromptForMandatory) {
                $CombinedPrompt = $Prompt
            } else {
                $CombinedPrompt = "$Prompt (you must provide a value)"
            }
        }
        Write-Host "$CombinedPrompt`: " -NoNewline -ForegroundColor Green
        if ($IsSecureString) {
            $Value = Read-Host -AsSecureString
        }
        else {
            
            $Value = Read-Host
        }

        if ($Value -and $Value.Length -gt 0) {
            return $Value
        } elseif ($DefaultValue) {
            return $DefaultValue
        }

        $PromptForMandatory = $true
    }
    while ($true)
}
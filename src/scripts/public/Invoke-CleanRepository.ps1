function Invoke-CleanRepository {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([void])]

    Param ()

    if (-not $PSBoundParameters.ContainsKey('ErrorAction')) { [System.Management.Automation.ActionPreference] $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop }
    if (-not $PSBoundParameters.ContainsKey('InformationAction')) { [System.Management.Automation.ActionPreference] $InformationPreference = [System.Management.Automation.ActionPreference]::Continue }
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { [System.Management.Automation.ActionPreference] $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') } else { [bool] $Verbose = $true }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { [System.Management.Automation.ActionPreference] $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { [System.Management.Automation.ActionPreference] $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }

    if ($PSCmdlet.ShouldProcess('Cleans up repository after deployment of resources')) {
        try {
            $null = Set-Location -Path $env:ES_REPO_NAME

            'Fetching latest origin changes.'
            StartExecution {
                git fetch
            } | Out-Host

            [string] $SourceBranch = 'deploy/{0}' -f $env:AZDEVOPS_SOURCE_BRANCH
            'Removing branch ({0}).' -f $SourceBranch
            StartExecution {
                git checkout $SourceBranch
                git push origin --delete $SourceBranch
            } | Out-Host
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}

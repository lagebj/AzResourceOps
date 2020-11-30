function New-SubscriptionDeployment {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]

    Param ()

    if (-not $PSBoundParameters.ContainsKey('ErrorAction')) { [System.Management.Automation.ActionPreference] $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop }
    if (-not $PSBoundParameters.ContainsKey('InformationAction')) { [System.Management.Automation.ActionPreference] $InformationPreference = [System.Management.Automation.ActionPreference]::Continue }
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { [System.Management.Automation.ActionPreference] $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') } else { [bool] $Verbose = $true }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { [System.Management.Automation.ActionPreference] $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { [System.Management.Automation.ActionPreference] $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }

    if ($PSCmdlet.ShouldProcess('Deploys subscription ARM templates')) {
        try {
            [Microsoft.Azure.Commands.Profile.Models.PSAzureSubscription[]] $Subscriptions = Get-AzSubscription
            [System.IO.FileInfo[]] $TemplateFile = GetTemplates

            $Subscriptions | ForEach-Object {
                if ([string[]] $TemplatesToDeploy = $TemplateFile | Where-Object -Property 'Directory' -like ('*{0}*' -f $_.SubscriptionId) | Select-Object -ExpandProperty 'FullName') {
                    'Found new resources for subscription {0}.' -f $_.Name
                    'Initializing ARM template.'
                    $SubscriptionTemplateFile = InitializeSubscriptionTemplate $TemplatesToDeploy

                    if (Test-Path -Path $SubscriptionTemplateFile) {
                        'ARM template created in {0}.' -f $SubscriptionTemplateFile
                        'Setting Azure context to {0}.' -f $_.Name
                        $null = Set-AzContext -SubscriptionObject $_

                        'Deploying ARM template {0} into subscription {1}.' -f $SubscriptionTemplateFile, $_.Name
                        [hashtable] $DeploymentParameters = @{
                            Name = 'azResourceOps_{0}' -f ((New-Guid).Guid.Substring(0,8))
                            Location = $env:AZRESOURCEOPS_DEFAULT_DEPLOYMENT_REGION
                            TemplateFile = $SubscriptionTemplateFile
                            SkipTemplateParameterPrompt = $true
                            Confirm = $false
                        }
                        New-AzDeployment @DeploymentParameters
                    }
                } else {
                    'Could not find any new resources for subscription {0}.' -f $_.Name
                    return
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}

function InitializeSubscriptionTemplate {
    [CmdletBinding()]
    [OutputType([string])]

    Param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]] $TemplateFile
    )

    try {
        [string] $TemplateFilePath = 'AzResourceOps\azResourceOps_{0}.json' -f ((New-Guid).Guid.Substring(0,8))
        [pscustomobject] $TemplateObject = @'
            {
                "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "variables": {},
                "resources": [],
                "outputs": {}
            }
'@ | ConvertFrom-Json

        [System.Collections.Generic.List[string]] $WarningMessages = @()

        [System.Collections.Generic.List[pscustomobject]] $ResourcesToDeploy = @()

        $TemplateFile | ForEach-Object {
            if ([string] $ResourceGroupName = GetDeploymentResourceGroup $_) {
                [pscustomobject] $ResourceObject = @'
                    {
                        "type": "Microsoft.Resources/deployments",
                        "apiVersion": "2020-06-01",
                        "name": "",
                        "resourceGroup": "",
                        "properties": {
                            "mode": "Incremental",
                            "expressionEvaluationOptions": {
                                "scope": "Inner"
                            },
                            "parameters": {},
                            "template": {}
                        }
                    }
'@ | ConvertFrom-Json

                $ResourceObject.name = ('azResourceOps_{0}' -f ((New-Guid).Guid.Substring(0,8)))
                $ResourceObject.resourceGroup = $ResourceGroupName
                $ResourceObject.properties.template = Get-Content -Path $_ | ConvertFrom-Json

                if (-not $ResourceObject.properties.template.parameters) {
                    $ResourceObject.properties | Add-Member -MemberType 'NoteProperty' -Name 'parameters' -Value $null
                }

                $ResourceObject.properties.template.parameters = [pscustomobject] @{
                    input = [pscustomobject] @{
                        type = 'object'
                    }
                }

                if ([string] $ParameterFile = (Resolve-Path -Path ('{0}\{1}.parameters.json' -f (Split-Path $_), (Split-Path $_ -LeafBase)) -ErrorAction 'SilentlyContinue').Path) {
                    [pscustomobject] $ParameterObject = Get-Content -Path $ParameterFile | ConvertFrom-Json

                    if (-not $ParameterObject.parameters.input) {
                        $ParameterObject.parameters | Add-Member -MemberType 'NoteProperty' -Name 'input' -Value $null
                    }

                    [string[]] $ParametersToConvert = ($ParameterObject.parameters | Get-Member -MemberType 'NoteProperty').Name

                    if ($ParametersToConvert -ne 'input') {
                        [pscustomobject] $InputObject = [pscustomobject] @{
                            input = [pscustomobject] @{
                                value = [pscustomobject] @{}
                            }
                        }
                        $ParametersToConvert | ForEach-Object {
                            if (-not ($_ -eq 'input')) {
                                $InputObject.input.value | Add-Member -MemberType 'NoteProperty' -Name $_ -Value $ParameterObject.parameters.$_.value
                            }
                        }

                        $ParameterObject.parameters = $InputObject
                    }

                    $ResourceObject.properties.parameters = $ParameterObject.parameters
                } else {
                    $WarningMessages.Add(('Could not find parameter file for template {0}. Resource will not be deployed.') -f (Split-Path -Path $_ -Leaf))
                    return
                }

                if (-not ($ResourceObject.properties.template.'$schema' -match '\/deploymentTemplate.json\#')) {
                    $WarningMessages.Add(('Schema for template file {0} must be deploymentTemplate.json. Resource will not be deployed. See https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-syntax#template-format for details.' -f (Split-Path -Path $_ -Leaf)))
                    return
                }

                $ResourcesToDeploy.Add($ResourceObject)
            } else {
                [pscustomobject] $ResourceGroupObject = Get-Content -Path $_ | ConvertFrom-Json

                if ([string] $ParameterFile = (Resolve-Path -Path ('{0}\{1}.parameters.json' -f (Split-Path $_), (Split-Path $_ -LeafBase)) -ErrorAction 'SilentlyContinue').Path) {
                    [pscustomobject] $ParameterObject = Get-Content -Path $ParameterFile | ConvertFrom-Json

                    if (-not $ParameterObject.parameters.input) {
                        $ParameterObject.parameters | Add-Member -MemberType 'NoteProperty' -Name 'input' -Value $null
                    }

                    [string[]] $ParametersToConvert = ($ParameterObject.parameters | Get-Member -MemberType 'NoteProperty').Name

                    if ($ParametersToConvert -ne 'input') {
                        [pscustomobject] $InputObject = [pscustomobject] @{
                            input = [pscustomobject] @{
                                value = [pscustomobject] @{}
                            }
                        }
                        $ParametersToConvert | ForEach-Object {
                            if (-not ($_ -eq 'input')) {
                                $InputObject.input.value | Add-Member -MemberType 'NoteProperty' -Name $_ -Value $ParameterObject.parameters.$_.value
                            }
                        }

                        $ParameterObject.parameters = $InputObject
                    }

                    $ParameterObject.parameters.input.value.psobject.Properties | ForEach-Object {$ResourceGroupObject.resources[0].$($_.Name) = ($ParameterObject.parameters.input.value.psobject.Properties | Where-Object -Property 'Name' -eq $_.Name).Value}
                } else {
                    $WarningMessages.Add(('Could not find parameter file for template {0}. Resource group will not be deployed.') -f (Split-Path -Path $_ -Leaf))
                    return
                }
                $ResourcesToDeploy.Add($ResourceGroupObject.resources[0])
            }
        }

        [pscustomobject[]] $TemplateObject.resources = [pscustomobject[]] $ResourcesToDeploy | Sort-Object -Property 'type' -Descending

        if ($TemplateObject.resources) {
            $Template = $TemplateObject | ConvertTo-Json -Depth 30

            FormatTemplate $Template | Out-File $TemplateFilePath

            return $TemplateFilePath
        } else {
            throw 'No resources to deploy.'
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    } finally {
        if ($WarningMessages) {
            $WarningMessages | ForEach-Object {
                Write-Warning -Message $_
            }
        }
    }
}

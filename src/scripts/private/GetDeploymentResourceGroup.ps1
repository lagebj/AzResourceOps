function GetDeploymentResourceGroup {
    [CmdletBinding()]
    [OutputType([string])]

    Param (
        [Parameter(Mandatory, Position = 0)]
        [string] $TemplateFile
    )

    try {
        [regex] $SubscriptionRegex = [regex]::new('(?i)[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}')
        [string] $TemplateParentFolder = ($TemplateFile.Split([System.IO.Path]::DirectorySeparatorChar))[-2]

        if ($TemplateParentFolder -match $SubscriptionRegex -or $TemplateParentFolder -eq '.AzState') {
            return
        }

        return $TemplateParentFolder
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}

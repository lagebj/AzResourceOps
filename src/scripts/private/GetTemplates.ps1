function GetTemplates {
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo[]])]

    Param ()

    try {
        [string] $RootPath = (Resolve-Path -Path ('{0}\azops' -f $env:AZOPS_REPO_NAME)).Path

        [hashtable] $ChildItemParameters = @{
            Path = '{0}\*' -f $RootPath
            Filter = '*.json'
            Exclude = '*.parameters.json'
            Recurse = $true
        }
        [System.IO.FileInfo[]] $TemplateFiles = Get-ChildItem @ChildItemParameters

        $TemplateFiles | Where-Object -Property 'Directory' -notlike '*.AzState*'
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}


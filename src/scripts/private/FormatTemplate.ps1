function FormatTemplate {
    [CmdletBinding()]
    [OutputType([string])]

    Param (
        [Parameter(Mandatory, Position = 0)]
        [string] $Template
    )

    try {
        [regex] $Pattern = [regex]::new('(?i)((?:parameters\([''"])(\w+)(?:[''"]\)))')

        $TemplatePatternMatches = $Template | Select-String -Pattern $Pattern -AllMatches

        $TemplatePatternMatches.Matches | ForEach-Object {
            if (-not ($_.Groups[2].Value -eq 'input')) {
                $Template = $Template.Replace($_.Value, ('parameters(''input'').{0}' -f $_.Groups[2].Value))
            }
        }

        return $Template
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}

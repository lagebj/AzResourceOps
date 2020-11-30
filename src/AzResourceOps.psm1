'scripts\private', 'scripts\public' | ForEach-Object {
    [string] $ModuleRoot = Join-Path -Path $PSScriptRoot -ChildPath $_
    if (Test-Path -Path $ModuleRoot) {
        Get-ChildItem -Path $ModuleRoot -Filter '*.ps1' -Recurse |
            Where-Object -Property 'Name' -notlike '*.Tests.ps1' |
                ForEach-Object {
                    . $_.FullName
                }
    }
}

Export-ModuleMember -Function (Get-ChildItem -Path ('{0}\scripts\public\*.ps1' -f $PSScriptRoot)).BaseName
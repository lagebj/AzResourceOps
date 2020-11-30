# Module manifest for module 'AzResourceOps'
# Generated by: Lage Berger Jensen
# Generated on: 15.11.2020

@{
    RootModule        = 'AzResourceOps.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '15f99ab5-dc3b-4442-9d82-2e396b0c8f5b'
    Author            = 'Lage Berger Jensen'
    CompanyName       = ''
    Copyright         = '(c) 2020 Lage Berger Jensen. All rights reserved.'
    Description       = 'Extension module for AzOps.'
    FunctionsToExport = @(
        'New-SubscriptionDeployment',
        'Invoke-CleanRepository'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    # CompatiblePSEditions = @()
    # PowerShellVersion = ''
    # PowerShellHostName = ''
    # PowerShellHostVersion = ''
    # DotNetFrameworkVersion = ''
    # CLRVersion = ''
    # ProcessorArchitecture = ''
    # RequiredModules = @()
    # RequiredAssemblies = @()
    # ScriptsToProcess = @()
    # TypesToProcess = @()
    # FormatsToProcess = @()
    # NestedModules = @()
    # DscResourcesToExport = @()
    # ModuleList = @()
    # FileList = @()
    PrivateData       = @{
        PSData = @{
            # Tags = @()
            LicenseUri = 'https://github.com/lagebj/AzResourceOps/blob/master/LICENSE'
            ProjectUri = 'https://github.com/lagebj/AzResourceOps'
            # IconUri = ''
            ReleaseNotes = 'https://github.com/lagebj/AzResourceOps/blob/master/ReleaseNotes.md'
        }
    }
    # HelpInfoURI = ''
    DefaultCommandPrefix = 'AzResOps'
}
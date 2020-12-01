#!/usr/bin/pwsh

'Prepare modules.'
[string[]] $Modules = @(
    'Az.Accounts',
    'Az.Resources'
)
$null = Install-Module -Name $Modules -Scope 'CurrentUser' -Force
$null = Import-Module ('.\{0}\src\AzResourceOps.psd1' -f $env:AZRESOURCEOPS_REPO_NAME)

if (Get-Module -Name 'AzResourceOps') {
    'Connecting to Azure.'
    [pscustomobject] $CredentialObject = ($env:AZURE_CREDENTIALS | ConvertFrom-Json)
    [pscredential] $Credential = [pscredential]::new($CredentialObject.clientId, ($CredentialObject.clientSecret | ConvertTo-SecureString -AsPlainText -Force))

    [hashtable] $ConnectionParameters = @{
        TenantId = $CredentialObject.tenantId
        ServicePrincipal = $true
        Credential = $Credential
        SubscriptionId = $CredentialObject.subscriptionId
        WarningAction = 'SilentlyContinue'
    }
    $null = Connect-AzAccount @ConnectionParameters

    'Initiating deployment.'
    New-AzResOpsSubscriptionDeployment

    'Cleaning up repository.'
    Invoke-AzResOpsCleanRepository
}
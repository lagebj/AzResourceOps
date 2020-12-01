# AzResourceOps

Bring your own ARM templates to Enterprise-scale.

## Objectives

This is an IaC module created to be used as an "extension" to Microsoft [Enterprise-scale](https://github.com/Azure/Enterprise-Scale) and [AzOps](https://github.com/Azure/AzOps).
The main focus of this project is to supplement [AzOps](https://github.com/Azure/AzOps) functionality and allow for deployment of all types of resources from within your Enterprise-scale repo without having to modify the Enterprise-scale code maintained by Microsoft.

The philosophy is that you "bring your own ARM templates" to handle deployment of resources at resource group level.

## Scope

AzResourceOps is not meant to replace AzOps functionality. You should still use AzOps to deploy resources within the scope of AzOps, like:

- Management Group hierarchy and Subscription organization
    - ResourceTypes:
        - Microsoft.Management/managementGroups
        - Microsoft.Management/managementGroups/subscriptions
        - Microsoft.Subscription/subscriptions
- Policy Definition and Policy Assignment for Governance
    - ResourceTypes:
        - Microsoft.Authorization/policyDefinitions
        - Microsoft.Authorization/policySetDefinitions
        - Microsoft.Authorization/policyAssignments
- Role Definition and Role Assignment
    - ResourceTypes:
        - Microsoft.Authorization/roleDefinitions
        - Microsoft.Authorization/roleAssignments

## How it works

You drop your ARM template(s) and associated parameter file in the folder where you want your resource(s) deployed. For resource groups this will be the folder of the subscription in your Enterprise-scale repo where you want your resource group deployed. For all other resources this will be the folder of the resource group where you want your resources deployed.
AzResourceOps searches the `azops` folder in your Enterprise-scale repo for any new template/parameter pairs, parses the files and creates a new subscription deployment ARM template containing all resources as nested deployments. Do not place your files in the `.AzState` folders as these will not be searched by AzResourceOps.

The example pipeline [azresourceops-push.yml](/.azure-pipelines/azresourceops-push.yml) must be set up in your Enterprise-scale repo and all pushes must be done to branches with name starting with `deploy/`, the pipeline will only trigger when pushes are done to branches starting with this name (unless changed).

If pipeline succeeds, AzResourceOps deletes the `deploy/*` branch without merging anything to the main branch of your Enterprise-scale repo. This is to avoid cluttering the main repo.

## Prerequisites

To start using AzResourceOps you need

- An existing [Enterprise-scale](https://github.com/Azure/Enterprise-Scale) repo setup.
- A service principal with Contributor permissions on subscriptions where you will deploy resources. You can use the SP already created for Enterprise-scale, for instance.

## Getting Started

- Clone this repository to your organization (currently only tested in Azure DevOps within the same organization as Enterprise-scale repo). The AzResourceOps repo must be possible to checkout from pipeline in your Enterprise-scale repo.
- Copy file `\.azure-pipelines\azresourceops-push.yml` to your Enterprise-scale repo.
- Change azresourceops-push.yml to reflect your environment. `ES_REPO_NAME` is the name of your Enterprise-scale repo, `AZRESOURCEOPS_REPO_NAME` is the name of your AzResourceOps repo. The folder in `FilePath` must be the name of the AzResourceOps repo (same as `AZRESOURCEOPS_REPO_NAME`).
    ![AzResourceOps pipeline YAML](./media/azresourceops-push.png)
- Create a new pipeline in Enterprise-scale repo from `azresourceops-push.yml`.
- Create a new secret pipeline variable called AZURE_CREDENTIALS containing your service principal, quotation marks should be escaped with `\`.
    ```json
    {
        \"clientId\": \"xxxx-xxxx-xxxx-xxxx-xxxxx\",
        \"displayName\": \"AzOps\",
        \"name\": \"http://AzOps\",
        \"clientSecret\": \"xxxxxx-xxxx-xxxx-xxxx-xxxxxx\",
        \"tenantId\": \"xxxxxx-xxxx-xxxx-xxxx-xxxxxx\",
        \"subscriptionId\": \"xxxxxx-xxxx-xxxx-xxxx-xxxxxx\"
    }
    ```

## How to use AzResourceOps

AzResourceOps requires a parameter file for each ARM template you wish to deploy. The parameter file has to have the same name as the ARM template with `*.parameters.json` appendend. I.ex. if you deploy a new Key Vault and the ARM template is called `keyVault.json`, your parameter file will have to be named `keyVault.parameters.json`.

Unless changed, the pipeline will trigger by default on push to all branches called `deploy/*`, where `*` can be whatever you want.

To deploy a new resource:

- Make sure to pull latest changes from `main`.
- Create a new branch in your Enterprise-scale repo called `deploy/whateveryouwanthere`.
- Copy your ARM template(s) and parameter file(s) to the resource group folder where you want to deploy the resources. If the resource group does not exist, you will need to deploy the resource group first (see [Limitations](#Limitations)).
- Resource group deployment file(s) will be placed in the folder of the subscription where you want to deploy the resource group(s).

## Limitations

- AzResourceOps is currently only tested in Azure DevOps, not GitHub or any other services.
- Requires parameter file for all templates.
- Deployment of resources assume that resource group already exists. You cannot deploy a new resource group and a new resource into the same resource group in the same operation, these deployments will have to be separated.

## Contributing

There are probably a lot of scenarios and tests that should be covered and this project welcomes any contributions and suggestions.

## More Information

For more information:

* [AzOps](https://github.com/Azure/AzOps)
* [Enterprise-scale](https://github.com/Azure/Enterprise-Scale)

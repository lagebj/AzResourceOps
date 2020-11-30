# AzResourceOps

Bring your own ARM templates to Enterprise-scale.

## Objectives

This module is created to be used as an extension to Microsoft [AzOps project](https://github.com/Azure/AzOps) and [Enterprise-scale](https://github.com/Azure/Enterprise-Scale).
The main focus of this project is to extend [AzOps](https://github.com/Azure/AzOps) functionality with a "Bring-Your-Own-ARM-Template" mindset to handle resources at resource group level.

### AzOps

AzResourceOps is not built to replace AzOps functionality to deploy resources within the scope of AzOps.

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

## Prerequisites

To start using AzResourceOps you need

- An existing [Enterprise-scale](https://github.com/Azure/Enterprise-Scale) repo setup.
- A service principal with Contributor permissions on subscriptions where you will deploy resources.

## Getting Started

- Clone this repository to your organization (currently only tested in Azure DevOps).
- Copy file \.azure-pipelines\azresourceops-push.yml to your Enterprise-scale repo.
- Change azresourceops-push.yml to reflect your environment.
    ![AzResourceOps pipeline YAML](./media/azresourceops-push.png)
- Create a new pipeline from azresourceops-push.yml.
- Create a new secret pipeline variable called AZURE_CREDENTIALS containing your service principal
    ```json
    {
        "clientId": "xxxx-xxxx-xxxx-xxxx-xxxxx",
        "displayName": "AzOps",
        "name": "http://AzOps",
        "clientSecret": "xxxxxx-xxxx-xxxx-xxxx-xxxxxx",
        "tenantId": "xxxxxx-xxxx-xxxx-xxxx-xxxxxx",
        "subscriptionId": "xxxxxx-xxxx-xxxx-xxxx-xxxxxx"
    }
    ```

## How to use

## Limitations

- AzResourceOps is currently only tested in Azure DevOps, not GitHub or any other services.
- Deployments are done at subscription level, you will not be able to use

## More Information

For more information

* [AzResourceOps.readthedocs.io](http://AzResourceOps.readthedocs.io)
* [github.com/lagebj/AzResourceOps](https://github.com/lagebj/AzResourceOps)
* [lagebj.github.io](https://lagebj.github.io)

This project was generated using [Lage Berger Jensen](http://lagebj.github.io)'s [Plastered Plaster Template](https://github.com/lagebj/PlasterTemplates/tree/master/Plastered).

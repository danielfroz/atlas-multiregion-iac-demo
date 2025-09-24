# Introduction

This repository is a simple Infrastructure as Code (IaC) example of an Azure multi-region application using MongoDB Atlas with multi-region support (Replica Set).

If you're feeling brave, go ahead and execute the scripts... have fun!

# Prerequisites

## Atlas

You must create an Atlas Account and a dedicated Organization for this demo.
Since we're going to provision multiple resources, the API Key must have the 'Organization Owner' privilege.
Once you're done with this demo, you can destroy it using the `cd iac && sh ./destroy.sh` script.
Keep in mind that it will also delete your Atlas organization! 
Again, create one organization for this exercise - don't use it in production environments!

### Organization ID

Copy the Organization ID and add it to the `iac/main.tf` file (see import {} section).

To obtain the Organization ID, go to Organization Settings. 
You can see the organization ID from the URL: https://cloud.mongodb.org/v2#/org/&lt;ORGANIZATION_ID&gt;/...
Copy it and save it!

### API Key

Generate the API Key at the organization level.

Click on `Access Manager`, then `Applications`, then `API Keys`. Generate the API Key with `Organization Owner` privilege.

Copy the Public and Private Keys - save them!

Note: Use the API Access List feature to restrict access to the Atlas Control Plane with this API Key!

## Azure

We are using the Azure Service Principal as the authentication method for this demo.
Follow the documentation available at Terraform's AzureRM Provider ([Creating a Service Principal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret))

Here are the commands you need to execute:
```shell
az login
az account list
az account set --subscription="20000000-0000-0000-0000-000000000000"
az ad sp create-for-rbac -n "IAC" --role="Contributor" --scopes="/subscriptions/20000000-0000-0000-0000-000000000000"
```

Copy the output and save it!

## env.sh Secrets

Make sure you create the `iac/env.sh` script file.

Here is an example of the file (replace values with the responses from the previous commands):

```shell
#!/bin/sh

export ARM_CLIENT_ID=00000000-0000-0000-0000-000000000000
export ARM_CLIENT_SECRET=12345678-0000-0000-0000-000000000000
export ARM_TENANT_ID=10000000-0000-0000-0000-000000000000
export ARM_SUBSCRIPTION_ID=20000000-0000-0000-0000-000000000000
export MONGODB_ATLAS_PUBLIC_KEY=YOUR_PUBLIC_KEY
export MONGODB_ATLAS_PRIVATE_KEY=YOUR_PRIVATE_KEY
```

# Provisioning the Resources

Use Terraform and execute the scripts from the `iac` directory.

Execute the scripts below:
- `sh ./plan.sh`
- `sh ./apply.sh`

Note: It may take 20 minutes to provision the Atlas cluster - wait for the response.

# Testing the Cluster

I created a simple API service for testing purposes.
It will work with the `account` database, `contract` collection.

Copy the source code to the VMs you have provisioned. Use the VM's public IP address.
Also remember that we created an `azureuser` with the password defined in the `iac/main.tf` file.

To use it, make sure you create the `.env` file under the application's folder (path: `/app/.env`).

Here is an example of the .env file:
```shell
MONGODB_URL=mongodb+srv://app:ChangeMe123!@prd-pl-0.CLUSTER.mongodb.net/?retryWrites=true&w=majority&appName=service
```

_ps: if you customized the password (which is recommended), then replace the ChangeMe123! database password for the one you created._

There are two options for running the application: Docker Compose or Deno run directly.

- Deno: use the `sh ./dev.sh` script.
- Docker Compose: execute the `docker compose build && docker compose up -d` command.

## Online Archive Private Endpoint

For detailed notes on OA Private Endpoint creation, please refer to the [README.md](./iac/README.md) inside the `iac` directory.

# Done with testing

Execute the `sh ./destroy.sh`.

AGAIN! THIS WILL DELETE YOUR ORGANIZATION AND ALL RESOURCES CREATED.
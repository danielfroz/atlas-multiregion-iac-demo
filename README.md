# Introduction

This repo is a simple IaC example of an Azure multi-region application using MongoDB Atlas deployed multiregion support (RS).

If you're feeling brave, go ahead and execute the scripts... have fun!

# Prerequisites

## Atlas

You shall create the Atlas Account and a dedicated Organization for this Demo. 
Since we're going to provision multiple resources, the API Key must have the 'Organization Owner' privilege.
Once you're done with this demo, you can destroy it using the `cd iac && sh ./destroy.sh` script.
Keep in mind that it will also delete your Atlas organization! Again, create one organization for this exercise - don't use it on production environments!!!!

### Organization Id

Copy the Organization Id and add it to the `iac/main.tf` file (see import {} section).

In order to obtain the Organization Id, go to Organization Settings, you can see the organization id from the URL (cloud.mongodb.org/v2#/org/&lt;ORGANIZATION_ID&gt;/...)

Copy it and save it!

### API Key

Generate the API Key at the organization level.

Click on `Access Manager`, and then `Applications`, then `API Keys`. Generate the API Key with `Organization Owner` privilege.

Copy the Public and Private Keys - save it!

Note: Use API Access List feature to restrict access to the Atlas Control Plane with this API Key!

## Azure

We are utilizing the Azure Service Principal as auth method on this Demo.
Follow the doc available at Terraform's Azurerm Provider ([Creating a Service Principal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret))

Here are the commands that you need to execute:
```shell
az login
az account list
az account set --subscription="20000000-0000-0000-0000-000000000000"
az ad sp create-for-rbac -n "IAC" --role="Contributor" --scopes="/subscriptions/20000000-0000-0000-0000-000000000000"
```

Copy the output and save it!

## .env.sh Secrets

Make sure you create the `iac/env.sh` script file.

Here is the example of the file (replace values with the responses from the previous commands):

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

Use terraform and execute the scripts from the `iac` directory.

Execute the scripts below:
- `sh ./plan.sh`
- `sh ./apply.sh`

ps: It may take 20 mins to provision the Altas cluster - wait for the response.

# Testing the Cluster

I created a simple api service for testing purposes. 
It will work with `account` database, `contract` collection.

Copy the source code to the VMs you have provisioned. Use the VMs public IP address. 
Also remember that we created a `azureuser` with the password defined on the `iac/main.ft` file.

To use it, make sure you create the `.env` file under the application's folder (path: `/app/.env`). 

Here is the example of .env file:
```shell
MONGODB_URL=mongodb+srv://app:MYPASSWORD!@prd-pl-0.CLUSTER.mongodb.net/?retryWrites=true&w=majority&appName=service
```

There are two options for running the application: Docker compose or deno run directly.

- Deno: use the `sh ./dev.sh` script.
- Docker compose: execute the `docker compose build && docker compose up -d` command.

## Online Archive Private Endpoint

For detailed notes, please refer to the [README.md](./iac/README.md) inside the iac directory.

# Done with testing

Execute the `sh ./destroy.sh`.

AGAIN! THIS WILL DELETE YOUR ORGANIZATION AND ALL RESOURCES CREATED.
# Online Archive Private Endpoint Setup

You must follow the installation instructions provided on Atlas UI for the creation of Private Endpoints on Data Federation or Online Archive.
For that, click on Security &gt; Network Access &gt; Private Endpoint &gt; Federated Database Instance / Online Archive &gt; +Create New Endpoint

## Steps

Here are the steps:

1. Select Azure as Cloud Provider
2. Select North America, Virginia East2 (eastus2)
3. Click on Next.
4. Resource Group Name: prd-eastus2-rg
5. Virtual Network Name: prd-eastus2-vnet
6. Subnet id (execute the command: `az network vnet subnet list --vnet-name prd-eastus2-vnet --resource-group prd-eastus2-rg --query "[].id"`)
7. Private Endpoint Name: prd-eastus-oa
8. Execute the command below to create the private endpoint:

```shell
az network private-endpoint create --connection-name connection-1 --name prd-eastus2-oa --private-connection-resource-id /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/pl-lb-prod-adl-pl-prod/providers/Microsoft.Network/privateLinkServices/pl-adl-pl-prod-eastus2-cloud-0-0 --resource-group prd-eastus2-rg --subnet /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/prd-eastus2-rg/providers/Microsoft.Network/virtualNetworks/prd-eastus2-vnet/subnets/prd-eastus2-subnet --vnet-name prd-eastus2-vnet --location eastus2 --query "{privateEndpointId:id, networkInterfaceId:networkInterfaces[0].id}" --manual-request true
```

As output, we have the following response:
```shell
{
  "networkInterfaceId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/prd-eastus2-rg/providers/Microsoft.Network/networkInterfaces/prd-eastus2-oa.nic.2455026c-f121-4a99-b560-5c54bf657057",
  "privateEndpointId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/prd-eastus2-rg/providers/Microsoft.Network/privateEndpoints/prd-eastus2-oa"
}
```

Add the information as indicated on the corresponding fields: Network Interface Id and Private Endpoint Id

9. Finish the creation with Confirm button
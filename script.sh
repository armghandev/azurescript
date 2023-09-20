#!/bin/bash

# Define your variables
userAzureLoginId="armghanbashir@emumbapvtgmail.onmicrosoft.com"  # Replace with your Azure login ID
#subscriptionId="<Your Subscription ID>"  # Replace with your Azure subscription ID
#resourceGroupName="<Your Resource Group Name>"  # Replace with your desired resource group name

# List available subscriptions
az login
# List all service principals
az ad sp list --query "[?contains(displayName, 'my-ZTNA-09-18-2023-02-45-54')]" --output table

echo "Available Subscriptions:"
az account list --query "[].{Name:name, ID:id}" --output table
read -p "Enter the Subscription ID: " subscriptionId

# List available resource groups
echo "Available Resource Groups:"
az group list --subscription $subscriptionId --query "[].{Name:name}" --output table
read -p "Enter the Resource Group Name: " resourceGroupName

# Generate a timestamp
timestamp=$(date +'%m-%d-%Y-%H-%M-%S')

# Create a service principal
servicePrincipalName="my-ZTNA-$timestamp"
roleName="Contributor"  # Replace with the desired role name
scope="/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName"  # Replace with your specific scope
# Create the service principal and assign a role
az ad sp create-for-rbac --name "$servicePrincipalName" --role "$roleName" --scopes "$scope"
sleep 60
# Get the service principal details
appId=$(az ad sp list --all --query "[?displayName == '$servicePrincipalName'].appId" --output tsv)
tenantID=$(az account show --query 'tenantId' -o tsv)
aadAppClientId=$(az ad app show --id '$appId' --query 'appId' -o tsv)
#aadAppClientSecret=$(az ad app credential reset --id "$appId" --credential-description "Service Principal Credential" --query 'password' -o tsv)
aadAppClientSecret=$(az ad sp credential reset --id "$appId"  --query 'password' -o table)
#object_id=$(az rest --method GET --url "https://graph.windows.net/myorganization/servicePrincipals?\$filter=displayname eq '$servicePrincipalName'&api-version=1.6" --query '[0].objectId' --output tsv)
#aadAppClientSecret=$(az ad app credential reset --name "$aadAppClientId" --credential-description "Service Principal Credential" --query 'password' -o tsv)
# Get the user's object ID
#userObjectId=$(az ad user show --upn "$userAzureLoginId" --query 'objectId' -o tsv)
# Print the outputs
echo "AAD App Client ID: $appId"
echo "Subscription ID: $subscriptionId"
echo "Tenant ID: $tenantID"
echo "AAD App Client ID: $aadAppClientId"
echo "AAD App Client Secret: $aadAppClientSecret"
echo "User Object ID: $userObjectId"

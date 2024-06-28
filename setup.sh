#!/bin/bash

# Variables
RESOURCE_GROUP=test-example$RANDOM-rg
STORAGE_ACCOUNT_NAME=testexample$RANDOM
WEBAPP_NAME=testwebapp$RANDOM
APPSERVICE_PLAN_NAME=testExampleAppServicePlan$RANDOM

# Create resource group
az group create --name $RESOURCE_GROUP --location eastus
echo "Resource group created"

# Create storage account
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location eastus --sku Standard_LRS
echo "Storage account created"

# Create an App Service plan
az appservice plan create --name $APPSERVICE_PLAN_NAME --resource-group $RESOURCE_GROUP --sku B1 --is-linux
echo "App service plan created"

# Create a Web App
az webapp create --resource-group $RESOURCE_GROUP --plan $APPSERVICE_PLAN_NAME --name $WEBAPP_NAME --runtime "java|21-java21"
echo "App created"

# Create managed identity for webapp
az webapp identity assign --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME
echo "Managed identity created"

# Wait and retry mechanism for managed identity propagation
MAX_RETRIES=10
RETRY_COUNT=0
SLEEP_INTERVAL=10

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    # Get the principal id of the managed identity
    PRINCIPAL_ID=$(az webapp identity show --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --query principalId --output tsv)

    if [ -n "$PRINCIPAL_ID" ]; then
        echo "Managed identity principal ID obtained: $PRINCIPAL_ID"
        break
    else
        echo "Retry $((RETRY_COUNT+1))/$MAX_RETRIES: Waiting for managed identity to propagate..."
        RETRY_COUNT=$((RETRY_COUNT+1))
        sleep $SLEEP_INTERVAL
    fi
done

if [ -z "$PRINCIPAL_ID" ]; then
    echo "Failed to obtain managed identity principal ID after $MAX_RETRIES retries. Exiting..."
    exit 1
fi

# Get the storage account id
STORAGE_ACCOUNT_ID=$(az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query id --output tsv)

# Retry mechanism for role assignment
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    az role assignment create --assignee $PRINCIPAL_ID --role "Storage Blob Data Contributor" --scope $STORAGE_ACCOUNT_ID

    if [ $? -eq 0 ]; then
        echo "Managed identity assigned to storage"
        break
    else
        echo "Retry $((RETRY_COUNT+1))/$MAX_RETRIES: Waiting for role assignment to propagate..."
        RETRY_COUNT=$((RETRY_COUNT+1))
        sleep $SLEEP_INTERVAL
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "Failed to assign role to managed identity after $MAX_RETRIES retries. Exiting..."
    exit 1
fi

# Output the client ID of the managed identity
CLIENT_ID=$(az webapp identity show --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --query clientId --output tsv)
echo "Managed Identity Client ID: $CLIENT_ID"

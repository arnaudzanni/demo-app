RESOURCE_GROUP="my-container-apps-group"
ENVIRONMENT_NAME="my-storage-environment"
LOCATION="canadacentral"
CONTAINER_APP_NAME="my-container-app"
STORAGE_ACCOUNT_NAME="myacastorageaccount21509"
STORAGE_SHARE_NAME="myfileshare"
STORAGE_MOUNT_NAME="mystoragemount"
REGISTRY_NAME="planetscore"
IDENTITY_NAME="myidentity"
SUBSCRIPTIONS_ID="7f628226-29c8-4404-b5e8-67e50ef62ff5"
IDENTITY_CLIENT_ID="2db723d8-fcda-4ed1-ba33-8e2981e8bc88"
IDENTITY_ID="/subscriptions/7f628226-29c8-4404-b5e8-67e50ef62ff5/resourcegroups/my-container-apps-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myidentity"

# Create a resource group.
az group create --name $RESOURCE_GROUP --location $LOCATION --query "properties.provisioningState"

# Create a Container Apps environment.
az containerapp env create --name $ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP --location "$LOCATION" --query "properties.provisioningState"

# Create an Azure Storage account.
az storage account create --resource-group $RESOURCE_GROUP --name $STORAGE_ACCOUNT_NAME --location "$LOCATION" --kind StorageV2 --sku Standard_LRS --enable-large-file-share --query provisioningState

# Create the Azure Storage file share.
az storage share-rm create --resource-group $RESOURCE_GROUP --storage-account $STORAGE_ACCOUNT_NAME --name $STORAGE_SHARE_NAME --quota 1024 --enabled-protocols SMB --output table

# Get the storage account key.
STORAGE_ACCOUNT_KEY=`az storage account keys list -n $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv`

# Create the storage link in the environment.
az containerapp env storage set --access-mode ReadWrite --azure-file-account-name $STORAGE_ACCOUNT_NAME --azure-file-account-key $STORAGE_ACCOUNT_KEY --azure-file-share-name $STORAGE_SHARE_NAME --storage-name $STORAGE_MOUNT_NAME --name $ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP --output table


# Create the user-assigned managed identity
az identity create --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

# Assign the AcrPull role to the identity for the Azure Container Registry.
az role assignment create --assignee $IDENTITY_CLIENT_ID --role AcrPull --scope /subscriptions/$SUBSCRIPTIONS_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerRegistry/registries/$REGISTRY_NAME

### MY-IMAGE
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ENVIRONMENT_NAME \
    --image planetscore.azurecr.io/backend:dev \
    --min-replicas 1 \
    --max-replicas 1 \
    --target-port 8000 \
    --ingress external \
    --registry-server $REGISTRY_NAME.azurecr.io \
    --query properties.configuration.ingress.fqdn \
    --identity userAssigned \
    --user-assigned-identity $IDENTITY_ID
# Create the container app.
### NGINX
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ENVIRONMENT_NAME \
    --image nginx \
    --min-replicas 1 \
    --max-replicas 1 \
    --target-port 80 \
    --ingress external \
    --query properties.configuration.ingress.fqdn
    
### MY-IMAGE
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ENVIRONMENT_NAME \
    --image planetscore.azurecr.io/backend:dev \
    --min-replicas 1 \
    --max-replicas 1 \
    --target-port 8000 \
    --ingress external \
    --registry-server $REGISTRY_NAME.azurecr.io \
    --query properties.configuration.ingress.fqdn \
    --identity userAssigned \
    --user-assigned-identity $IDENTITY_ID


# Create the container app.
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ENVIRONMENT_NAME \
    --image planetscore.azurecr.io/backend:dev \
    --min-replicas 1 \
    --max-replicas 1 \
    --target-port 8000 \
    --ingress external \
    --registry-server $REGISTRY_NAME.azurecr.io \
    --system-assigned \
    --query properties.configuration.ingress.fqdn

# Export the container app's configuration.
az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --output yaml > app.yaml

az containerapp update --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --yaml app.yaml --output table

az containerapp delete -g $RESOURCE_GROUP -n $CONTAINER_APP_NAME --yes
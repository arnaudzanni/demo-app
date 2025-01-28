CONTAINER_APP_NAME=backend-dev
RESOURCE_GROUP=planetscore

az containerapp show \
-n $CONTAINER_APP_NAME \
-g $RESOURCE_GROUP \
-o yaml > $CONTAINER_APP_NAME.yaml


# Add volume information into container app yaml configuration file

# Mount Volumes to Container App
MSYS_NO_PATHCONV=1 az containerapp update \
--name $CONTAINER_APP_NAME \
--resource-group $RESOURCE_GROUP \
--yaml $CONTAINER_APP_NAME.yaml


#################################################################################################################################
########################################### ARM #################################################################################
#################################################################################################################################

RESOURCE_GROUP=ARMbased
LOCATION=francecentral

az group create --name $RESOURCE_GROUP --location $LOCATION

# Get loganalytics_key
# az monitor log-analytics workspace get-shared-keys --resource-group planetscore --workspace-name workspace-planetscoreAP2b --query "primarySharedKey"


az deployment group create \
    --name "exampleDeployment" \
    --resource-group $RESOURCE_GROUP \
    --template-file 02-container-app.json \
    --parameters @02-container-app.parameters.json

az group delete --resource-group $RESOURCE_GROUP --yes
// general Azure Container App settings
@description('Location for resources')
param location string = resourceGroup().location

@description('Name of the Container App')
param containerAppName string

@description('Name of the Container Registry')
param acrName string

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${containerAppName}-identity' // Creating a new user-assigned managed identity
  location: location
}

// Reference the Azure Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

// Assign the AcrPull role to the user-assigned managed identity
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, userAssignedIdentity.id, 'AcrPull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    ) // AcrPull Role Definition ID
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal' // Specify the principal type
  }
  dependsOn: [
    containerRegistry
  ]
}

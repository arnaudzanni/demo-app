// general Azure Container App settings
@description('Location for resources')
param location string = resourceGroup().location

@description('Name of the Container App')
param containerAppName string
param containerAppEnvironmentId string

@description('The container image to be deployed')
param containerImage string

// Networking
param useExternalIngress bool = false
param containerPort int

param acrName string
param userAssignedIdentityName string

param envVars array = []

// Reference the Azure Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

// Reference the Azure Container Registry
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: userAssignedIdentityName
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    environmentId: containerAppEnvironmentId
    configuration: {
      registries: [
        {
          identity: userAssignedIdentity.id
          server: containerRegistry.properties.loginServer
        }
      ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
    }
    template: {
      containers: [
        {
          image: '${containerRegistry.properties.loginServer}/${containerImage}'
          name: containerAppName
          env: envVars
          resources: {
            cpu: 1
            memory: '2Gi'
          }
          volumeMounts: [
            {
              mountPath: '/app/data'
              volumeName: 'my-file-share'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
      }
      volumes: [
        {
          name: 'my-file-share'
          storageName: 'my-storage-link'
          storageType: 'AzureFile'
        }
      ]
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn

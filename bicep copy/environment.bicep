param name string

@description('The location of the Azure Container App environment.')
param location string = resourceGroup().location

resource law 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
  name: name
}

var lawClientId = law.properties.customerId
var lawClientSecret = law.listKeys().primarySharedKey

resource env 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: lawClientId
        sharedKey: lawClientSecret
      }
    }
  }
}

@description('The storage account name for Azure File Share.')
param storageAccountName string

@description('The Azure File Share name to mount.')
param fileShareName string

@description('The name of the storage link.')
param storageMountName string = 'my-storage-link'

// Get the storage account resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

// Retrieve the access keys for the storage account
var storageAccountKeys = storageAccount.listKeys()
var storageAccountKey = storageAccountKeys.keys[0].value

resource storageAccountLink 'Microsoft.App/managedEnvironments/storages@2023-05-01' = {
  name: storageMountName
  parent: env
  properties: {
    azureFile: {
      accessMode: 'ReadWrite'
      accountName: storageAccountName
      accountKey: storageAccountKey
      shareName: fileShareName
    }
  }
}

output id string = env.id

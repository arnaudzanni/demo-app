@description('Location for the Log Analytics Workspace and Key Vault.')
param location string

@description('Name of the Key Vault.')
param keyVaultName string

@description('Prefix for Key Vault admin object ID (used for access policy).')
param keyVaultAdminObjectId string

// Create Key Vault to store secrets
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: keyVaultAdminObjectId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
          ]
        }
      }
    ]
  }
}

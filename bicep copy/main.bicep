param location string = resourceGroup().location
param envName string = 'blog-sample'

param containerImage string
param containerPort int

module law 'law.bicep' = {
  name: 'log-analytics-workspace'
  params: {
    location: location
    name: 'law-${envName}'
  }
}

module identity 'identity.bicep' = {
  name: 'user-assigned-identity'
  params: {
    location: location
    containerAppName: 'sample-app'
    acrName: 'planetscore'
  }
}

module containerAppEnvironment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: envName
    location: location
    storageAccountName: 'planetscoresa'
    fileShareName: 'planetscoreshare-dev'
  }
}

module containerApp 'containerapp.bicep' = {
  name: 'sample'
  params: {
    containerAppName: 'sample-app'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    containerPort: containerPort
    envVars: [
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
      }
    ]
    useExternalIngress: true
    acrName: 'planetscore'
    userAssignedIdentityName: identity.name
  }
}
output fqdn string = containerApp.outputs.fqdn

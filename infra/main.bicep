targetScope = 'resourceGroup'

@description('The environment name (e.g. dev, test, prod).')
param environmentName string = 'dev'

@description('The Azure region where resources will be deployed.')
param location string = resourceGroup().location

@description('A unique token used to ensure globally unique resource names.')
param resourceToken string = uniqueString(subscription().subscriptionId, resourceGroup().id, environmentName)

var tags = {
  environment: environmentName
  project: 'cosmos'
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    name: 'stcosmos${resourceToken}'
    location: location
    tags: tags
  }
}

module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: 'asp-cosmos-${environmentName}-${resourceToken}'
    location: location
    tags: tags
  }
}

module applicationInsights 'modules/applicationInsights.bicep' = {
  name: 'applicationInsights'
  params: {
    name: 'appi-cosmos-${environmentName}-${resourceToken}'
    location: location
    tags: tags
  }
}

module functionApp 'modules/functionApp.bicep' = {
  name: 'functionApp'
  params: {
    name: 'func-cosmos-${environmentName}-${resourceToken}'
    location: location
    tags: tags
    storageAccountName: storageAccount.outputs.name
    appServicePlanId: appServicePlan.outputs.id
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
  }
}

output functionAppName string = functionApp.outputs.name
output functionAppHostname string = functionApp.outputs.defaultHostName

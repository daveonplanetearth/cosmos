@description('Name of the App Service Plan')
param appServicePlanName string

@description('Name of the Web App')
param webAppName string

@description('Azure region for the resources')
param location string

@description('Application Insights connection string')
param appInsightsConnectionString string

@description('Resource tags')
param tags object = {}

@description('SKU for the App Service Plan')
param skuName string = 'B1'

@description('Operating system for the App Service Plan')
@allowed(['linux', 'windows'])
param osType string = 'linux'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: osType == 'linux' ? 'linux' : 'app'
  properties: {
    reserved: osType == 'linux'
  }
}

// App Service (Web App)
resource webApp 'Microsoft.Web/sites@2024-04-01' = {
  name: webAppName
  location: location
  tags: tags
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: osType == 'linux' ? 'DOTNETCORE|10.0' : null
      netFrameworkVersion: osType == 'windows' ? 'v10.0' : null
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
      ]
    }
  }
}

@description('Default hostname of the Web App')
output defaultHostname string = webApp.properties.defaultHostName

@description('Web App resource ID')
output id string = webApp.id

@description('Web App name')
output name string = webApp.name

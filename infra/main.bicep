@description('Base name used to derive all resource names')
param appName string = 'cosmos'

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, test, prod)')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('SKU for the App Service Plan')
param appServicePlanSku string = 'B1'

@description('Operating system for the App Service Plan')
@allowed(['linux', 'windows'])
param osType string = 'linux'

// Generate consistent resource names
var suffix = '${appName}-${environment}'
var appServicePlanName = 'plan-${suffix}'
var webAppName = 'app-${suffix}'
var appInsightsName = 'appi-${suffix}'
var logAnalyticsWorkspaceName = 'log-${suffix}'

var tags = {
  application: appName
  environment: environment
  managedBy: 'bicep'
}

// Application Insights + Log Analytics
module monitoring 'modules/appinsights.bicep' = {
  name: 'monitoring'
  params: {
    appInsightsName: appInsightsName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location
    tags: tags
  }
}

// App Service Plan + Web App
module appService 'modules/appservice.bicep' = {
  name: 'appservice'
  params: {
    appServicePlanName: appServicePlanName
    webAppName: webAppName
    location: location
    appInsightsConnectionString: monitoring.outputs.connectionString
    skuName: appServicePlanSku
    osType: osType
    tags: tags
  }
}

@description('URL of the deployed Web App')
output webAppUrl string = 'https://${appService.outputs.defaultHostname}'

@description('Application Insights connection string')
output appInsightsConnectionString string = monitoring.outputs.connectionString

@description('Web App name')
output webAppName string = appService.outputs.name

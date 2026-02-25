# Cosmos

An Azure App Service application built with .NET 10 (C#), featuring structured logging via Serilog and telemetry via Application Insights.

## Project Structure

```
cosmos/
├── src/
│   └── CosmosApi/          # .NET 10 ASP.NET Core Web API
│       ├── Controllers/     # API controllers
│       ├── Program.cs       # Application entry point (Serilog + App Insights)
│       └── appsettings.json # Configuration including Serilog settings
├── infra/
│   ├── main.bicep           # Main Bicep entry point
│   ├── main.bicepparam      # Default parameter values
│   └── modules/
│       ├── appservice.bicep # App Service Plan + Web App module
│       └── appinsights.bicep# Application Insights + Log Analytics module
└── Cosmos.sln
```

## Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) (for deployment)
- [Bicep CLI](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install) (included in Azure CLI 2.20+)

## Running Locally

```bash
cd src/CosmosApi
dotnet run
```

The API will be available at `https://localhost:5001` (or the port shown in the console).

Endpoints:
- `GET /weatherforecast` – Sample weather forecast data
- `GET /health` – Health check

## Deploying to Azure

### 1. Create a Resource Group

```bash
az group create --name rg-cosmos-dev --location eastus
```

### 2. Deploy Infrastructure with Bicep

```bash
az deployment group create \
  --resource-group rg-cosmos-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

To override parameters at deploy time:

```bash
az deployment group create \
  --resource-group rg-cosmos-dev \
  --template-file infra/main.bicep \
  --parameters appName=cosmos environment=prod appServicePlanSku=P1v3
```

### 3. Publish the Application

```bash
dotnet publish src/CosmosApi -c Release -o ./publish

az webapp deploy \
  --resource-group rg-cosmos-dev \
  --name app-cosmos-dev \
  --src-path ./publish \
  --type zip
```

## Telemetry & Logging

### Application Insights
Application Insights telemetry is configured via the `ApplicationInsights:ConnectionString` app setting. This is automatically set when deploying with the Bicep templates.

To enable locally, set the connection string in `appsettings.Development.json`:

```json
{
  "ApplicationInsights": {
    "ConnectionString": "InstrumentationKey=...;IngestionEndpoint=..."
  }
}
```

### Serilog
Structured logging is provided by [Serilog](https://serilog.net/). The configuration lives in `appsettings.json` under the `Serilog` key.

Default sinks:
- **Console** – Human-readable output during development and in Azure App Service log stream

To add the Application Insights sink at runtime (production), add the `APPLICATIONINSIGHTS_CONNECTION_STRING` environment variable/app setting and the sink picks it up automatically via the Application Insights SDK.

## Bicep Modules

| Module | Description |
|--------|-------------|
| `modules/appservice.bicep` | Creates an App Service Plan and Web App configured for .NET 10 |
| `modules/appinsights.bicep` | Creates a Log Analytics Workspace and workspace-based Application Insights instance |

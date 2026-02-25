# Cosmos Azure Function

An Azure Functions v4 app built with **.NET 10** using the **isolated worker model**.

## Features

- **HTTP Trigger** – sample function that responds to GET/POST requests
- **Application Insights telemetry** – distributed tracing, metrics, and live metrics
- **Structured logging** – via `ILogger<T>` with configurable log levels in `host.json`
- **Bicep infrastructure** – ready-to-deploy Azure resources

## Project structure

```
cosmos/
├── src/
│   └── CosmosFunction/
│       ├── CosmosFunction.csproj   # .NET 10 isolated worker project
│       ├── Program.cs              # Host builder with telemetry & logging
│       ├── host.json               # Function host configuration
│       ├── local.settings.json     # Local development settings (not deployed)
│       └── Functions/
│           └── HttpTriggerFunction.cs
└── infra/
    ├── main.bicep                  # Top-level Bicep orchestration
    ├── main.bicepparam             # Parameter file
    └── modules/
        ├── storageAccount.bicep
        ├── appServicePlan.bicep    # Consumption (Y1) plan
        ├── applicationInsights.bicep
        └── functionApp.bicep       # Linux function app + RBAC storage access
```

## Local development

### Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)
- [Azure Functions Core Tools v4](https://learn.microsoft.com/azure/azure-functions/functions-run-local)
- [Azurite](https://learn.microsoft.com/azure/storage/common/storage-use-azurite) (local storage emulator)

### Run locally

```bash
cd src/CosmosFunction
func start
```

The HTTP trigger is available at:

```
GET/POST http://localhost:7071/api/HttpTrigger?code=<function-key>
```

## Deploy to Azure

### Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- An Azure subscription

### Create infrastructure with Bicep

```bash
# Create a resource group
az group create --name rg-cosmos-dev --location eastus

# Deploy the infrastructure
az deployment group create \
  --resource-group rg-cosmos-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

### Publish the function app

```bash
dotnet publish src/CosmosFunction/CosmosFunction.csproj -c Release -o ./publish

FUNC_APP_NAME=$(az deployment group show \
  --resource-group rg-cosmos-dev \
  --name main \
  --query properties.outputs.functionAppName.value -o tsv)

func azure functionapp publish "$FUNC_APP_NAME" --dotnet-isolated
```

## Configuration

| Setting | Description |
|---------|-------------|
| `AzureWebJobsStorage` | Storage account connection (use `UseDevelopmentStorage=true` locally) |
| `FUNCTIONS_WORKER_RUNTIME` | Must be `dotnet-isolated` |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Application Insights connection string |

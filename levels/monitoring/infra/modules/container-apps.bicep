@description('Container Apps Environment ID')
param containerAppsEnvironmentId string

@description('Location for all resources')
param location string

@description('Tags for all resources')
param tags object

@description('Container Registry login server')
param containerRegistryServer string

@description('Managed Identity ID for ACR access')
param identityId string

@description('Application Insights connection string for distributed tracing')
param appInsightsConnectionString string

@description('Sanitize Function URL for PII redaction')
param sanitizeFunctionUrl string = ''

@description('Enable server-side PII sanitization (default: true for Module 4)')
param sanitizeEnabled bool = true

// Workshop MCP Server - Pre-provisioned with placeholder
resource WorkshopMcpServer 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'Workshop-mcp-server'
  location: location
  tags: union(tags, {
    'azd-service-name': 'Workshop-mcp-server'
  })
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8000
        transport: 'http'
        allowInsecure: false
      }
      registries: [
        {
          server: containerRegistryServer
          identity: identityId
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'Workshop-mcp-server'
          // Public placeholder - azd deploy will replace with actual image from ACR
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            {
              name: 'PORT'
              value: '8000'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsightsConnectionString
            }
            {
              name: 'OTEL_SERVICE_NAME'
              value: 'Workshop-mcp-server'
            }
            {
              name: 'SANITIZE_FUNCTION_URL'
              value: sanitizeFunctionUrl
            }
            {
              name: 'SANITIZE_ENABLED'
              value: string(sanitizeEnabled)
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

// Path API - Pre-provisioned with placeholder
resource PathApi 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'Path-api'
  location: location
  tags: union(tags, {
    'azd-service-name': 'Path-api'
  })
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8000
        transport: 'http'
        allowInsecure: false
      }
      registries: [
        {
          server: containerRegistryServer
          identity: identityId
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'Path-api'
          // Public placeholder - azd deploy will replace with actual image from ACR
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            {
              name: 'PORT'
              value: '8001'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsightsConnectionString
            }
            {
              name: 'OTEL_SERVICE_NAME'
              value: 'Path-api'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

// Outputs for waypoint scripts
output WorkshopServerFqdn string = WorkshopMcpServer.properties.configuration.ingress.fqdn
output WorkshopServerUrl string = 'https://${WorkshopMcpServer.properties.configuration.ingress.fqdn}'
output PathApiFqdn string = PathApi.properties.configuration.ingress.fqdn
output PathApiUrl string = 'https://${PathApi.properties.configuration.ingress.fqdn}'

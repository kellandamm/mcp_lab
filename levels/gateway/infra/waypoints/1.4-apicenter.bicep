// Waypoint 1.4: Register APIs in API Center
// Registers MCP servers for discoverability

param apiCenterName string
param apimGatewayUrl string

resource apiCenter 'Microsoft.ApiCenter/services@2024-03-01' existing = {
  name: apiCenterName
}

// Use default workspace (API Center free tier only allows 1 workspace)
resource defaultWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-01' existing = {
  parent: apiCenter
  name: 'default'
}

// Register Workshop MCP Server
resource WorkshopRegistration 'Microsoft.ApiCenter/services/workspaces/apis@2024-03-01' = {
  parent: defaultWorkspace
  name: 'Workshop-mcp'
  properties: {
    title: 'Workshop MCP Server'
    summary: 'Weather forecasts, Path conditions, and gear recommendations for mountain adventures'
    description: 'MCP Server providing real-time weather data, Path status updates, and personalized gear recommendations. Secured with OAuth 2.0 via Azure API Management at ${apimGatewayUrl}/Workshop/mcp'
    kind: 'mcp'
    externalDocumentation: [
      {
        title: 'MCP Specification'
        url: 'https://modelcontextprotocol.io'
      }
    ]
  }
}

// Register PATHS MCP Server
resource PATHSMcpRegistration 'Microsoft.ApiCenter/services/workspaces/apis@2024-03-01' = {
  parent: defaultWorkspace
  name: 'PATHS-mcp'
  properties: {
    title: 'PATHS MCP Server'
    summary: 'Path information, permit management, and hiking conditions'
    description: 'MCP Server for browsing PATHS, checking conditions, and managing hiking permits. Secured with OAuth 2.0 via Azure API Management at ${apimGatewayUrl}/PATHS/mcp'
    kind: 'mcp'
    externalDocumentation: [
      {
        title: 'MCP Specification'
        url: 'https://modelcontextprotocol.io'
      }
    ]
  }
}

output workspaceId string = defaultWorkspace.id

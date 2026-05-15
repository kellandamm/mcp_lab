// Waypoint 1.3: Register APIs in API Center
// Registers MCP servers for discoverability

param apiCenterName string
param apimName string
param apimGatewayUrl string

resource apiCenter 'Microsoft.ApiCenter/services@2024-03-01' existing = {
  name: apiCenterName
}

// Create workspace for MCP servers
resource mcpWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-01' = {
  parent: apiCenter
  name: 'mcp-servers'
  properties: {
    title: 'MCP Servers'
    description: 'Model Context Protocol servers for AI assistants'
  }
}

// Register Workshop MCP Server
resource WorkshopRegistration 'Microsoft.ApiCenter/services/workspaces/apis@2024-03-01' = {
  parent: mcpWorkspace
  name: 'Workshop-mcp'
  properties: {
    title: 'Workshop MCP Server'
    description: 'MCP Server for weather, PATHS, and gear recommendations'
    kind: 'rest'  // Note: API Center doesn't have MCP type yet
    lifecycleStage: 'production'
    externalDocumentation: [
      {
        title: 'MCP Specification'
        url: 'https://modelcontextprotocol.io'
      }
    ]
    customProperties: {
      mcpEndpoint: '${apimGatewayUrl}/Workshop-mcp/mcp'
      transportType: 'streamable'
    }
  }
}

// Register Path API
resource PathRegistration 'Microsoft.ApiCenter/services/workspaces/apis@2024-03-01' = {
  parent: mcpWorkspace
  name: 'Path-api'
  properties: {
    title: 'Path API'
    description: 'REST API for Path information and permits'
    kind: 'rest'
    lifecycleStage: 'production'
    customProperties: {
      restEndpoint: '${apimGatewayUrl}/PATHS'
    }
  }
}

output workspaceId string = mcpWorkspace.id

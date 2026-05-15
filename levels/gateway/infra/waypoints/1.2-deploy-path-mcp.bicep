// Waypoint 1.2: Export Path API as MCP Server
// Creates an MCP API that wraps the REST API operations as MCP tools
// Pattern from: https://github.com/Azure-Samples/AI-Gateway/tree/main/labs/mcp-from-api

param apimName string
param apiName string = 'Path-api'
param productName string = 'Path-services'

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimName
}

// Reference the existing REST API
resource PathApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' existing = {
  parent: apim
  name: apiName
}

// Reference the existing Product
resource PathProduct 'Microsoft.ApiManagement/service/products@2024-06-01-preview' existing = {
  parent: apim
  name: productName
}

// Reference each operation from the REST API
resource listPATHSOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = {
  parent: PathApi
  name: 'list-PATHS'
}

resource getPathOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = {
  parent: PathApi
  name: 'get-Path'
}

resource checkConditionsOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = {
  parent: PathApi
  name: 'check-conditions'
}

resource getPermitOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = {
  parent: PathApi
  name: 'get-permit'
}

resource requestPermitOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = {
  parent: PathApi
  name: 'request-permit'
}

// Create MCP API that exposes REST operations as MCP tools
resource PathMcp 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'Path-mcp'
  properties: {
    type: 'mcp'
    displayName: 'Path MCP Server'
    description: 'MCP server exposing Path and permit operations as tools'
    subscriptionRequired: true  // Same security as REST API
    path: 'PATHS'              // APIM path: /PATHS/mcp
    protocols: ['https']
    mcpTools: [
      {
        name: listPATHSOp.name
        operationId: listPATHSOp.id
        description: listPATHSOp.properties.description
      }
      {
        name: getPathOp.name
        operationId: getPathOp.id
        description: getPathOp.properties.description
      }
      {
        name: checkConditionsOp.name
        operationId: checkConditionsOp.id
        description: checkConditionsOp.properties.description
      }
      {
        name: getPermitOp.name
        operationId: getPermitOp.id
        description: getPermitOp.properties.description
      }
      {
        name: requestPermitOp.name
        operationId: requestPermitOp.id
        description: requestPermitOp.properties.description
      }
    ]
  }
}

// Add MCP API to the Path Services Product (uses same subscription as REST API)
resource PathMcpProductLink 'Microsoft.ApiManagement/service/products/apis@2024-06-01-preview' = {
  parent: PathProduct
  name: PathMcp.name
}

output PathMcpId string = PathMcp.id
output mcpEndpoint string = '${apim.properties.gatewayUrl}/PATHS/mcp'

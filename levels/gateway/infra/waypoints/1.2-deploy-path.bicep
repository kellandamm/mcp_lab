// Waypoint 1.2: Deploy Path API to APIM
// Creates backend, API, Product, and subscription key (no OAuth yet)

param apimName string
param backendUrl string

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimName
}

// Backend pointing to Path API Container App
resource PathBackend 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  parent: apim
  name: 'Path-api-backend'
  properties: {
    title: 'Path API'
    description: 'Backend for Path API running in Container Apps'
    protocol: 'http'
    url: backendUrl
  }
}

// Path Services Product - bundles REST API and MCP server
resource PathProduct 'Microsoft.ApiManagement/service/products@2024-06-01-preview' = {
  parent: apim
  name: 'Path-services'
  properties: {
    displayName: 'Path Services'
    description: 'Access to Path REST API and MCP server'
    state: 'published'
    subscriptionRequired: true
    approvalRequired: false
  }
}

// Path API - exposed as REST API
// Path 'Pathapi' is the APIM URL prefix, urlTemplates go directly to backend
resource PathApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'Path-api'
  properties: {
    displayName: 'Path API'
    description: 'REST API for Path information and permit management'
    path: 'Pathapi'
    protocols: ['https']
    subscriptionRequired: true
    apiType: 'http'
    serviceUrl: backendUrl
  }
}

// Add REST API to Product
resource PathApiProductLink 'Microsoft.ApiManagement/service/products/apis@2024-06-01-preview' = {
  parent: PathProduct
  name: PathApi.name
}


// ============================================
// Path Operations
// ============================================

// GET /Pathapi/PATHS -> backend /PATHS
resource listPATHSOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: PathApi
  name: 'list-PATHS'
  properties: {
    displayName: 'List PATHS'
    description: 'List all available hiking PATHS'
    method: 'GET'
    urlTemplate: '/PATHS'
  }
}

// GET /Pathapi/PATHS/{PathId} -> backend /PATHS/{PathId}
resource getPathOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: PathApi
  name: 'get-Path'
  properties: {
    displayName: 'Get Path'
    description: 'Get details for a specific Path'
    method: 'GET'
    urlTemplate: '/PATHS/{PathId}'
    templateParameters: [
      {
        name: 'PathId'
        type: 'string'
        required: true
        description: 'Path identifier (e.g., summit-Path, base-Path)'
      }
    ]
  }
}

// GET /Pathapi/PATHS/{PathId}/conditions -> backend /PATHS/{PathId}/conditions
resource checkConditionsOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: PathApi
  name: 'check-conditions'
  properties: {
    displayName: 'Check Conditions'
    description: 'Get current Path conditions and hazards'
    method: 'GET'
    urlTemplate: '/PATHS/{PathId}/conditions'
    templateParameters: [
      {
        name: 'PathId'
        type: 'string'
        required: true
        description: 'Path identifier'
      }
    ]
  }
}

// ============================================
// Permit Operations
// ============================================

// GET /Pathapi/permits/{permitId} -> backend /permits/{permitId}
resource getPermitOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: PathApi
  name: 'get-permit'
  properties: {
    displayName: 'Get Permit'
    description: 'Retrieve a Path permit by ID'
    method: 'GET'
    urlTemplate: '/permits/{permitId}'
    templateParameters: [
      {
        name: 'permitId'
        type: 'string'
        required: true
        description: 'Permit identifier (e.g., PRM-2025-0001)'
      }
    ]
  }
}

// POST /Pathapi/permits -> backend /permits
resource requestPermitOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: PathApi
  name: 'request-permit'
  properties: {
    displayName: 'Request Permit'
    description: 'Request a new Path permit'
    method: 'POST'
    urlTemplate: '/permits'
  }
}

// Create a subscription for the Path Services Product
resource PATHSubscription 'Microsoft.ApiManagement/service/subscriptions@2024-06-01-preview' = {
  parent: apim
  name: 'Path-services-subscription'
  properties: {
    displayName: 'Path Services Access'
    state: 'active'
    scope: PathProduct.id
  }
}

output PathApiId string = PathApi.id
output PathBackendId string = PathBackend.id
output PathProductId string = PathProduct.id
output subscriptionKey string = PATHSubscription.listSecrets().primaryKey

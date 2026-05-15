// Waypoint 1.3: Apply Rate Limiting
// Adds rate limiting policy to Path API

param apimName string

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimName
}

// Reference Path API
resource PathApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' existing = {
  parent: apim
  name: 'Path-api'
}

// Apply Rate Limiting to Path REST API
resource PathPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = {
  parent: PathApi
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('../policies/ratelimit-only.xml')
  }
}

@description('Container Registry name')
param acrName string

@description('Workshop MCP Server Principal ID')
param WorkshopPrincipalId string

@description('Path API Principal ID')
param PathPrincipalId string

// Reference existing ACR
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

// ACR Pull role definition
var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// Grant Workshop MCP Server ACR Pull access
resource WorkshopAcrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, WorkshopPrincipalId, acrPullRoleDefinitionId, 'Workshop')
  scope: acr
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: WorkshopPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Path API ACR Pull access
resource PathAcrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, PathPrincipalId, acrPullRoleDefinitionId, 'Path')
  scope: acr
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: PathPrincipalId
    principalType: 'ServicePrincipal'
  }
}

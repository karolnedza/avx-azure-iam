################################################# 
data "azurerm_subscription" "current" {
  subscription_id = "5b27c9bd-f72d-4c75-8fdf-e06fadcd3308"
}

#################################################

resource "azurerm_role_definition" "subscription" {
  name        = "avx-subscription-role"
  scope       = data.azurerm_subscription.current.id
  description = "This is a custom role created for Aviatrix scope: Subcription"

  permissions {
    actions     = [     
      "Microsoft.MarketplaceOrdering/offerTypes/publishers/offers/plans/agreements/*",  # needed to deploy GW images 
      "Microsoft.Compute/*/read",
      #"Microsoft.Compute/availabilitySets/*",
      #"Microsoft.Compute/virtualMachines/*",
      "Microsoft.Network/*/read",
      #"Microsoft.Network/publicIPAddresses/*",
      #"Microsoft.Network/networkInterfaces/*",
      #"Microsoft.Network/networkSecurityGroups/*",
      #"Microsoft.Network/loadBalancers/*",
      #"Microsoft.Network/routeTables/*",
      #"Microsoft.Network/virtualNetworks/*",
      #"Microsoft.Storage/storageAccounts/*", 
      "Microsoft.Resources/*/read",
      "Microsoft.Resourcehealth/healthevent/*",
      #"Microsoft.Resources/deployments/*",
      "Microsoft.Resources/tags/read",                     # read is enough
      #"Microsoft.Resources/marketplace/purchase/action"   # works without
      #"Microsoft.Resources/subscriptions/resourceGroups/*"
      "Microsoft.Resources/subscriptions/resourceGroups/read" # read is enough
      ]
    not_actions = []
  }

  # assignable_scopes = [
  #   "(Optional) One or more assignable scopes for this Role Definition", 
  # ]
}

##########################################

variable "resource_group" {
  default = "avx-spoke-east-us-1"
}


resource "azurerm_role_definition" "resource-group" {
  name        = "avx-resource-group-role"
  scope       = "${data.azurerm_subscription.current.id}/resourcegroups/${var.resource_group}"
  description = "This is a custom role created for Aviatrix scope: Resource Group"

  permissions {
    actions     = [     
      #"Microsoft.MarketplaceOrdering/offerTypes/publishers/offers/plans/agreements/*",  # this is inherited from subscription 
      "Microsoft.Compute/*/read",
      "Microsoft.Compute/availabilitySets/*",
      "Microsoft.Compute/virtualMachines/*",
      "Microsoft.Network/*/read",
      "Microsoft.Network/publicIPAddresses/*",
      "Microsoft.Network/networkInterfaces/*",  
      "Microsoft.Network/networkSecurityGroups/*",
      "Microsoft.Network/loadBalancers/*",
      "Microsoft.Network/routeTables/*",
      "Microsoft.Network/virtualNetworks/*",
      #"Microsoft.Storage/storageAccounts/*",      # needed only for FW bootstrap 
      "Microsoft.Resources/*/read",
      "Microsoft.Resourcehealth/healthevent/*",
      "Microsoft.Resources/deployments/*",
      "Microsoft.Resources/tags/*",            
      #"Microsoft.Resources/marketplace/purchase/action"   
      #"Microsoft.Resources/subscriptions/resourceGroups/"
      #"Microsoft.Resources/subscriptions/resourceGroups/read" # this is inherited from subscription 
      ]
    not_actions = []
  }

  # assignable_scopes = [
  #   "(Optional) One or more assignable scopes for this Role Definition",
  # ]
}

##########################################

resource "azurerm_role_assignment" "aviatrix-app-subscription" {
  scope              = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.subscription.role_definition_resource_id
  principal_id       =  "74227686-a53a-434a-a893-05c488d3411a" # this is Service Principal ObjectID for Aviatrix Controller 
}


resource "azurerm_role_assignment" "aviatrix-app-resource-group" {
  scope              = "${data.azurerm_subscription.current.id}/resourcegroups/${var.resource_group}"
  role_definition_id = azurerm_role_definition.resource-group.role_definition_resource_id
  principal_id       =  "74227686-a53a-434a-a893-05c488d3411a" # this is Service Principal ObjectID for Aviatrix Controller 
}
locals {
  # Azure Regions with availability zones - unaware of an API 
  # https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
  az_support_by_region = {
    australiacentral   = false
    australiacentral2  = false
    australiaeast      = true
    australiasoutheast = false
    brazilsouth        = true
    brazilsoutheast    = false
    canadacentral      = true
    canadaeast         = false
    centralindia       = true
    centralus          = true
    eastasia           = true
    eastus             = true
    eastus2            = true
    francecentral      = true
    francesouth        = false
    germanynorth       = false
    germanywestcentral = true
    japaneast          = true
    japanwest          = false
    jioindiacentral    = false
    jioindiawest       = false
    koreacentral       = true
    koreasouth         = false
    northcentralus     = false
    northeurope        = true
    norwayeast         = true
    norwaywest         = false
    southafricanorth   = true
    southafricawest    = false
    southcentralus     = true
    southeastasia      = true
    southindia         = false
    swedencentral      = true
    switzerlandnorth   = false
    switzerlandwest    = false
    uaecentral         = false
    uaenorth           = false
    uksouth            = true
    ukwest             = false
    westcentralus      = false
    westeurope         = true
    westindia          = false
    westus             = false
    westus2            = true
    westus3            = true
  }
}
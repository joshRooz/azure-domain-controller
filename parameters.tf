# ARM Template - PARAMETERS
# in terraform no distinct parameters block exists. Define as variables
# where input should be limited to a list of options variable validation 
# can be applied.

variable "admin_username" {
  description = "Windows Virtual Machine Admin Username."
  type        = string
}

variable "admin_password" {
  description = "Windows Virtual Machine Admin Password."
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Active Directory Fully Qualified Domain Name."
  type        = string
}

variable "dns_prefix" {
  description = "DNS Prefix for the Load Balancer Public IP address."
  type        = string
}

variable "windows_server_version" {
  description = "The version of Windows Server to use."
  type        = string

  validation {
    condition = can(
      index(
        [
          "2016-Datacenter",
          "2019-Datacenter",
          "2022-Datacenter"
        ],
        var.windows_server_version
    ))
    error_message = "Windows Server Version (case sensitive) must be one of: 2016-Datacenter, 2019-Datacenter,2022-Datacenter."
  }
}

variable "dsc_function" {
  description = "DSC Configuration to apply to DC."
  type        = string

  validation {
    condition = can(
      index(
        [
          "ApplyNewDomain",
          "ApplyPromoteDC"
        ],
        var.dsc_function
    ))
    error_message = "DSC function (case sensitive) must be one of: ApplyNewDomain, ApplyPromoteDC."
  }
}

variable "_artifacts_location" {
  description = "The location of resources, such as templates and DSC modules, that the template depends on"
  type        = string
  default     = "https://raw.githubusercontent.com/joshrooz/azure-domain-controller/two/arm-to-tf-phase"
}

variable "_artifacts_location_sas_token" {
  description = "Auto-generated token to access _artifacts_location."
  type        = string
  default     = null
}

# I like to explicitly specify the subscription in the azurerm provider 
# as a safety net. Helpful if running local deployments with multiple
# tenants active in AZ CLI or multiple subscriptions/azurerm provider blocks
variable "subscription_id" {
  description = "Subscription ID for terraform deployment."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name."
  type        = string
}


# region list obtained 2021-12-21 - 
# az account list-locations \
# --query 'sort_by(@, &name)[?metadata.physicalLocation != null].name' \
# -o table
variable "region" {
  description = "Azure Region."
  type        = string

  validation {
    condition = can(
      index(
        [
          "australiacentral",
          "australiacentral2",
          "australiaeast",
          "australiasoutheast",
          "brazilsouth",
          "brazilsoutheast",
          "canadacentral",
          "canadaeast",
          "centralindia",
          "centralus",
          "eastasia",
          "eastus",
          "eastus2",
          "francecentral",
          "francesouth",
          "germanynorth",
          "germanywestcentral",
          "japaneast",
          "japanwest",
          "jioindiacentral",
          "jioindiawest",
          "koreacentral",
          "koreasouth",
          "northcentralus",
          "northeurope",
          "norwayeast",
          "norwaywest",
          "southafricanorth",
          "southafricawest",
          "southcentralus",
          "southeastasia",
          "southindia",
          "swedencentral",
          "switzerlandnorth",
          "switzerlandwest",
          "uaecentral",
          "uaenorth",
          "uksouth",
          "ukwest",
          "westcentralus",
          "westeurope",
          "westindia",
          "westus",
          "westus2",
          "westus3"
        ],
        lower(var.region)
      )
    )
    error_message = "The defined region is not a supported Azure public cloud region."
  }
}
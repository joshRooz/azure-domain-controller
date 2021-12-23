# ARM Template - VARIABLES

variable "virtual_network_name" {
  description = "Virtual Network Name."
  type        = string
  default     = "adVNET"
}

variable "virtual_network_address_range" {
  description = "Virtual Network Address Range."
  type        = string
  default     = "10.0.0.0/16"
}

variable "ad_load_balancer_frontend_name" {
  description = "AD Load Balancer Frontend Name."
  type        = string
  default     = "LBFE"
}

variable "ad_load_balancer_backend_name" {
  description = "AD Load Balancer Backend Name."
  type        = string
  default     = "LBBE"
}

variable "ad_remote_desktop_nat_name" {
  description = "AD Load Balancer NAT rule name for RDP."
  type        = string
  default     = "adRDP"
}

variable "ad_nic_name" {
  description = "AD Network Interface Card Name."
  type        = string
  default     = "adNic"
}

variable "ad_virtual_machine_name" {
  description = "AD Virtual Machine Name."
  type        = string
  default     = "adVM"

  validation {
    condition     = length(var.ad_virtual_machine_name) <= 15
    error_message = "A maximum length of 15 characters is enforced to maintain NETBIOS compatibity."
  }
}

variable "ad_subnet_name" {
  description = "AD Subnet Name."
  type        = string
  default     = "adSubnet"
}

variable "ad_subnet_address_prefix" {
  description = "AD Subnet Address Prefix."
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_ip_address_name" {
  description = "Public IP Address Name."
  type        = string
  default     = "adPublicIP"
}

variable "ad_availability_set_name" {
  description = "AD Availability Set Name"
  type        = string
  default     = "adAvailabilitySet"
}

variable "ad_load_balancer_name" {
  description = "AD Load Balancer Name."
  type        = string
  default     = "adLoadBalancer"
}

variable "ad_network_security_group_name" {
  description = "AD Network Security Group Name."
  type        = string
  default     = "adNsg"
}

# https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones?view=windows-11
variable "ad_virtual_machine_timezone" {
  description = "AD VM timezone."
  type        = string
  default     = "AUS Eastern Standard Time"
}
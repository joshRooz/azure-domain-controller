# Terraform deployment of an Active Directory Domain Controller

This branch deploys an Active Directory Domain Controller on an Azure VM. You can RDP to the Domain Controller through an Azure Load Balancer that is deployed along with the VM. Additional NAT rules can be created on the Load Balancer to support RDP for additional member servers you wish to deploy into the same VNET. The AD DS configuration is applied by a PowerShell DSC configuration located inside this repo.

# Usage
This branch assumes terraform local state, remote state will be enabled later
* `terraform init`
* `terraform validate`
* ```sh
  terraform plan \
    -var-file=example.tfvars \
    -var=admin_password=<your-actual-password> \
    -var=subscription_id=<your-subscription-id>
  ```
* ```sh
  terraform apply \
    -var-file=example.tfvars \
    -var=admin_password=<your-actual-password> \
    -var=subscription_id=<your-subscription-id>
  ```

# NOTES
If you jump to Standard SKU there are a few other changes... but be sure to include an outbound rule or your VM will lose internet connectivity. Eg:
```hcl
resource "azurerm_lb_outbound_rule" "this" {
  name                    = "OutboundRule"
  resource_group_name     = azurerm_resource_group.this.name
  loadbalancer_id         = azurerm_lb.this.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id

  frontend_ip_configuration {
    name = var.ad_load_balancer_frontend_name
  }
}
```

# Reference Links
* https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-template

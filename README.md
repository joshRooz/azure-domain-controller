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
I got tripped up (for the better part of a full day) by the Load Balancer conversion to terraform as an undocumented argument is required to maintain "Basic" SKU on the LB and Public IP. *UPDATE* -That's because it's no longer part of the schema... dropped a message in Terraform-Azure Slack channel to see what I'm missing. For now -
Public IP - Standard & Zone Support
Load Balancer - Standard & Zone Support
&& outbound rule resource directly below

To jump to Standard SKU - be sure to include an outbound rule or your VM will lose internet connectivity. Eg:
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

The load balancer deployed fine but terraform bombed with -
> Error: waiting for update of Backend Address Pool Address...
> 
> Code="Canceled" Message="Operation was canceled." 
> Details=[{"code":"CanceledAndSupersededDueToAnotherOperation","message":"Operation PutLoadBalancerBackendAddressPoolOperation was canceled and superseded by operation PutLoadBalancerOperation."}]

`terraform import -var-file=example.tfvars -var=subscription_id=<my-subscription> azurerm_lb_backend_address_pool_address.this /subscriptions/<my-subscription>/resourceGroups/rg-ad-test/providers/Microsoft.Network/loadBalancers/adLoadBalancer/backendAddressPools/LBBE/addresses/adVM`


# Reference Links
* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/
* https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-template
* https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/2021-07-01/virtualmachines/extensions?tabs=json

# ARM Template that builds an Active Directory Domain Controller

This template deploys an Active Directory Domain Controller on an Azure VM. You can RDP to the Domain Controller through an Azure Load Balancer that is deployed along with the VM. Additional NAT rules can be created on the Load Balancer to support RDP for additional member servers you wish to deploy into the same VNET. The AD DS configuration is applied by a PowerShell DSC configuration located inside this repo.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjoshrooz%2Fazure-domain-controller%2Fone%2Farm-digestion-phase%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>



# NOTES
azuredeploy.json - `_artifactsLocation` default value will use the `one/arm-digestion-phase` branch

```sh
az vm extension image list \
  -l australiasoutheast \
  -p Microsoft.PowerShell \
  -n DSC \
  --latest
```

```sh
az vm image list-skus \
  -l australiasoutheast \
  -f WindowsServer \
  -p MicrosoftWindowsServer \
  --query [].name
```

# Reference Links
* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/
* https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-template
* https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/2021-07-01/virtualmachines/extensions?tabs=json

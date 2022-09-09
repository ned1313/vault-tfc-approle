# Using the AppRole auth method with TFC

This Terraform configuration will be run from Terraform Cloud. The previous step created the workspace and populated the variables. In this step, you will need to update the `cloud` block in the `terraform.tf` file with the name of your organization in TFC.

Then it's a simple matter of running the standard Terraform workflow:

```bash
terraform init

terraform apply
```

The configuration will do the following:

* Authenticate to the Vault server using the AppRole auth method
* Use the Azure secrets engine to create a temporary Azure service principal
* Authenticate to Azure using the temporary service principal
* Create a new Azure resource group called `approle-test`

When the Terraform run is complete, you can check in the Azure portal or run this Azure CLI command to verify:
    
```bash
az group show --name approle-test
```

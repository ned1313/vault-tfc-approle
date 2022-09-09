# Provisioning an HCP Vault Cluster

You will need to first set up an HCP account and generate a service principal to use with Terraform. Directions can be found [here](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/guides/auth).

Make note of the service principal ID and secret and set them as environment variables: HCP_CLIENT_ID and HCP_CLIENT_SECRET.

```PowerShell
$env:HCP_CLIENT_ID = "CHANGE_ME"
$env:HCP_CLIENT_SECRET = "CHANGE_ME
```

```bash
export HCP_CLIENT_ID=CHANGE_ME
export HCP_CLIENT_SECRET=CHANGE_ME
```

The configuration uses a Terraform Cloud workspace named `tfc-vault-cluster`. If you want to use TFC, simply update the organization name in the `cloud` block in the `terraform.tf` file. If you'd rather use a different backend, then comment out the cloud block and add the appropriate backend configuration to the `backend` block.

If you're using a TFC workspace, you'll need to set up the corresponding environment and terraform variables:

| Variable Name | Type | Description |
| ------------- | ---- | ----------- |
| HCP_CLIENT_ID | env | The HCP client ID |
| HCP_CLIENT_SECRET | env | The HCP client secret (sensitive) |
| vault_cluster_id | terraform | The name of the HCP cluster |

Then simply run the standard Terraform commands to provision an HCP Vault cluster.

```bash
# Create the workspace
terraform init

# Configure the variables on the workspace through the UI

# Deploy the cluster
terraform apply -auto-approve
```

The outputs from the deployment will include the Vault cluster endpoint and an admin token. You will use these in the next step to configure the Vault server.

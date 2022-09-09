# Using Vault with Terraform Cloud

Here's the big idea. When you're using workspaces in Terraform Cloud (TFC) to provision infrastructure, you need credentials for Terraform to use against whatever clouds you're deploying on. What are your options for storing those credentials?

* Store it as an environment variable in the workspace
* Store it as an environment variable in a variable set
* Use a hosted runner with machine authentication
* Use Vault to dynamically generate credentials

There's pros and cons of each. Let's briefly review them and then circle back.

## Store it as an environment variable in the workspace

This works just fine if you only have a few workspaces. But as your workspace usage grows, you'll need to set it on every workspace that shares the same credentials. If you need to update those credentials, you'll need to go to **every workspace** and update the settings. This is tedious and error prone. Plus, it also implies many of your workspaces will be using the same credentials, which may or may not be what you want.

## Store it as an environment variable in a variable set

You can assign a variable set to one or more workspaces, so this solves the problem of adding the credentials to every workspace manually. It also solves the problem of rotating a credential. You've still got multiple workspaces using the same long-lived credentials, which is not ideal. I think for some folks this solution is perfectly acceptable.

## Use a hosted runner with machine authentication

By default, TFC uses runner machine hosted by HashiCorp on their infrastructure. Since the machines don't have an identity associated with your cloud accounts, they cannot use machine-based authentication to provision infrastructure. If you happen to be at the Business tier, you can run self-hosted agents ([Cloud Agents](https://www.terraform.io/cloud-docs/agents)) in your environment. Now you can use machine authentication, and you don't have to store credentials in TFC. Of course, that means you'll be managing a fleet of machines, and you'll need to control what roles each machine is assigned. You're probably not going to spin up a machine for every workspace, so you'll be sharing credentials once again.

## Use Vault to dynamically generate credentials

Instead of using these long-lived credentials, what if you could have Vault dynamically generate credentials for each Terraform run and then dispose of them after the run completes? That seems useful! Of course, now you need a way to authenticate back to Vault. There are a bunch of auth methods in Vault, but none of them are TFC. **Hey HashiCorp! That seems like a useful thing to add!!!**

Really all TFC needs to support is OIDC, which is already an auth method in Vault. But until TFC supports OIDC, we're stuck back at square one. If you want to use Vault, there are a few auth methods that make sense:

* AppRole: Store the Role ID and Secret ID in TFC
* Token: Store a super long lived token in TFC
* Cloud IAM: Use a hosted machine in one of the clouds

The first two options still require you to store some type of credential in TFC. You can store it with the workspace or as a variable set. On the bright side, if someone leaks the credentials, they are time bound and simple to revoke. And the interceptor would need to know the address of your Vault server and the auth method path on the Vault server. Unlike stored AWS or Azure credentials, where they could start reeking havoc right away.

The third option puts us back in the Business tier of TFC with a self-hosted runner.

Why don't we try setting up TFC to work with a Vault instance, leveraging the AppRole auth method. We'll need to store a Role ID and Secret ID. For our purposes, we won't set a TTL or limit the number of uses for the Secret ID. Generally speaking, you would generate a different Secret ID for each machine leveraging the role, but we just have TFC.

Again, this is not an ideal setup. I'd like a lower TTL and a process to generate new Secret IDs on a regular basis. Maybe that's an automated process that lives outside of TFC and leverage the TFE provider to regularly update the Secret IDs in TFC? I'd also recommend configuring a Role ID in a variable set, but configuring the Secret ID per workspace. It's easier to invalidate the secret used by a single workspace that way. That's more work for you to do, and that's the eternal tradeoff of security versus convenience.

## Demo Environment

The demonstration environment will leverage Terraform Cloud, a host Vault instance on HashiCorp Cloud Platform, and a subscription on Azure. You will first spin up a Vault server with a public endpoint. Then you will configure the Vault server with an AppRole auth method and the Azure secrets engine. Finally, you'll create a workspace on Terraform Cloud that uses the AppRole auth method and the Azure secrets engine to dynamically generate credentials for Azure and create a resource group in your Azure subscription.

The numbered directories will walk you through each step in the process. You will need to have a few prerequisites setup:

* A Terraform Cloud account (Free tier is fine)
* An HCP account (sign up is free with a $50 credit)
* An Azure subscription
  * Owner rights on the Azure subscription
  * Permissions on the Azure AD tenant to create service principals

### Deploying a Vault Server

Since TFC will be reaching out to the Vault server, Vault needs to have a public address. The easiest way to do that is to use a development instance on the HashiCorp Cloud Platform. You can sign up for a free account and get $50 in credit. The development instance only runs a few dollars a month, so that credit should last you a while.

You can also spin up a public facing Vault server yourself using one of the public cloud services. I actually have an example of using Azure ACI to spin up a Vault server with persistent storage.

The contents of the `1_setup_vault_server` directory will provision an HCP development instance. Just follow the directions in the README.md file in that directory.

### Configure Vault and Azure

In the `enable_approle` directory is a Terraform configuration that will create the following resources:

* Vault
  * AppRole auth method
  * Vault policy for AppRole role
  * AppRole role with role ID
  * AppRole secret ID for the role ID
  * Azure secrets backend
  * Azure secrets backend role with Contributor Access
* Azure
  * Azure AD application
  * Azure AD service principal
  * Role assignments to Microsoft Graph
  * Role assignment of Owner to the Azure Subscription

The service principal created in Azure AD will be used by Vault to provision dynamic service principals from the Azure secret method and grant them Contributor access on the current Azure subscription. In a real world scenario, you would have a list of subscriptions that you want to grant permissions to, and maybe multiple role IDs, one per environment.

Follow the README.md file in the directory to get things deployed.

### Using the AppRole auth method with TFC

The files in the `use_approle` directory will do the following:

* Vault
  * Authenticate to the provider using the Role ID and Secret ID we generated earlier
  * Use the Azure secrets data source to create an Azure service principal dynamically
* Azure
  * Authenticate to the provider using our shiny new service principal
  * Create a resource group

Follow the README.md file in the directory to get things working.

## GitHub Actions

Vault supports GitHub Actions with OIDC authentication. If you're storing your code in GitHub anyway, you could have GitHub Actions kick off when a PR or merge comes in to trigger a Terraform run on TFC. As part of the GitHub Actions, it could authenticate to Vault and generate a single use token for the Terraform run. Then TFC uses that token to dynamically generate whatever credentials it needs.

I actually have a whole separate repository about using OIDC on GitHub with Vault and I'll be presenting on exactly that at HashiConf Global 2022. I'll be talking about how to use the OIDC plugin for Vault, how to set up a GitHub repository, how to set up a GitHub Action, and how to use the OIDC plugin to authenticate to Vault. Once the presentation is available, I'll add a link to the repo.

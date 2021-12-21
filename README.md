# terraform-framework
this framework helps you to organize the terraform code for your environment. it gives you the structure to scale to multiple subscriptions and applications

# AZURE SETUP:  

Ensure you have the following created in Azure:
1. Service Principal for Terraform access
Service Principal will be used to connect to the Azure API. We need the following permissions for the SPN:
  i. API permissions
      Azure Active Directory Graph:
        Application:
          Application.ReadWrite.All
          Application.ReadWrite.Owned
          Directory.Read.All

  ii.RBAC Subscription : Contribute + User Access Management

2. Storage Account for Terraform State

3. Keyvault to store secrets

4. Deployment Machine
a linux virtual machine (Ubuntu / Redhat) to be used as a deployment machine

## Deployment Machine Dependencies
 - Ubuntu 18.04 (or any other linux distro)
 - az cli
 - terraform
 - jq library


ENVIRONMENT:  Create a copy of sub1 under /environments and name it your subscription (example:  lz-stage-360\centralus\360plus)

Modify terraform.tfvars – feature customizations


ORCHESTRATION:  Make a copy of parameters\whitekite and rename it to your subscription.
Modify pipeline.json for orchestration
Modify vars.json for Terraform state.


Run (from script directory):
```bash
bash susa.sh azure ../parameters/your-subs/pipeline.json --plan    # for plan

bash susa.sh azure ../parameters/your-subs/pipeline.json           # for apply

bash susa.sh azure ../parameters/your-subs/pipeline.json --destroy # for destroy
```
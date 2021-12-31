# Introduction
Susa, the Security Automation as Code framework, is introduced to check Security Requirements during the process of provisioning cloud infrastructure. The Security Automation as Code engine can deploy the resources to the cloud and can be run upon built-in or user-defined Security Policy containing Security Checklists, Security Templates, and Security Procedures. 

This secure Cloud Provisioning engine is an Open Source solution for automated Cloud Template provisioning and deployments. Susa provides a Command Line Interface (CLI) based on bash scripting technology which enables users to automate repetitive tasks in DevOps scenarios. Susa framework helps organizations to provide consistency across multiple clouds, projects, and environments deployed via IaC tools such as HashiCorp Terraform.

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
bash susa.sh azure ../parameters/azure/your-subs/pipeline.json --plan    # for plan

bash susa.sh azure ../parameters/azure/your-subs/pipeline.json           # for apply

bash susa.sh azure ../parameters/azure/your-subs/pipeline.json --destroy # for destroy
```

If you are unfamiliar with `susa` concept, you can run our configurator that will create a cloud configuration and simple pipeline example:
```
bash susa.sh azure --config
```
You will be asked for the following parameters:
```
What is the subscription name?
What is the subscription id?
What is the location? [centralus]
What is the resource group name?
What is the keyvault name?
What is the SPN name?
What is the SPN id?
What is the storage name?
```

# AWS SETUP:

Ensure you have the following created in A:
1. AWS IAM account (AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY)
  - Export this variables before framework usage:
```
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

2. S3 bucket for Terraform State

Run (from script directory):
```bash
bash susa.sh aws ../parameters/aws/your-subs/pipeline.json --plan    # for plan

bash susa.sh aws ../parameters/aws/your-subs/pipeline.json           # for apply

bash susa.sh aws ../parameters/aws/your-subs/pipeline.json --destroy # for destroy
```

If you are unfamiliar with `susa` concept, you can run our configurator that will create a cloud configuration and simple pipeline example:
```
bash susa.sh aws --config
```
You will be asked for the following parameters:
```
What is the account name?
What is default region? [us-east-1]
What is the S3 bucket name?
What is the S3 bucket region?
```

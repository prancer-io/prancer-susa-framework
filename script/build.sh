#!/bin/bash
set -e

#
# Usage
#

if [ $# -lt 1 ]; then
	echo "Usage:" >&2
    echo "  Provide absololute or relative path to deploy dir." >&2
    echo "  $0 ../parameters/subs1/pipeline.json [--destroy]" >&2
    exit 1
fi

#
# Check if pipeline exists
#

if [ -f "$1" ]; then
    deploy_file="$1"
else
    echo "Pipeline file doesn't exists!"
    exit 1
fi

#
# Parse arguments
#

export action="build"
for i in "$@"
do
    case $i in
        --destroy)
            export action="destroy"
            ;;
    esac
done

#
# Export variables
#

export PROVIDER_FILE="provider.tf"
export BACKEND_FILE="backend.tf"
export REPO_DIR=$(cd ../ && pwd)
export ENV_DIR="$REPO_DIR/environments"
export PARAM_DIR=$(cd ${deploy_file%/*} && pwd)
export PARAM_FILE="$PARAM_DIR/vars.json"

# Debugging:
# echo "PROVIDER_FILE = $PROVIDER_FILE"
# echo "BACKEND_FILE  = $BACKEND_FILE"
# echo "REPO_DIR      = $REPO_DIR"
# echo "ENV_DIR       = $ENV_DIR"
# echo "PARAM_DIR     = $PARAM_DIR"
# echo "PARAM_FILE    = $PARAM_FILE"

#
# Extract params
#

export TFSTATE_RG=$(jq -r .parameters.terraformSettings.value.name.resourceGroup $PARAM_FILE)
export TFSTATE_STORAGE=$(jq -r .parameters.terraformSettings.value.name.storage $PARAM_FILE)
export TFSTATE_CONTAINER="states"
export SUB_ID=$(jq -r .parameters.configurationSettings.value.name.subscriptionId $PARAM_FILE)
export CLIENT_ID=$(jq -r .parameters.terraformSettings.value.name.id $PARAM_FILE)
export NAME=$(jq -r .parameters.terraformSettings.value.name.spn $PARAM_FILE)
export VAULT=$(jq -r .parameters.terraformSettings.value.name.vault $PARAM_FILE)

# Debugging:
# echo "TFSTATE_RG        = $TFSTATE_RG"
# echo "TFSTATE_STORAGE   = $TFSTATE_STORAGE"
# echo "TFSTATE_CONTAINER = $TFSTATE_CONTAINER"
# echo "SUB_ID            = $SUB_ID"
# echo "CLIENT_ID         = $CLIENT_ID"
# echo "NAME              = $NAME"
# echo "VAULT             = $VAULT"

#
# Functions
#

function terraformPrepare {
    kv_key=$(getKeyvaultKey $TFSTATE_STORAGE $TFSTATE_RG)
    client_secret=$(getClientSecret "$NAME" "$VAULT")
    tenant_id=$(getTenantId)
    generateBackendFile "$kv_key"
    generateProviderFile "$SUB_ID" "$CLIENT_ID" "$client_secret" "$tenant_id"
}

function getKeyvaultKey {
    access_key=$(
        az storage account keys list -n $1 -g $2 | jq -r '.[1].value'
    )
    echo "$access_key"
}

function getClientSecret {
    client_secret=$(
        az keyvault secret show --name "$1" --vault-name "$2" --query value | tr -d '"'
    )
    echo "$client_secret"
}

function getTenantId {
    echo $(az account show --query tenantId | tr -d '"')
}

function generateProviderFile {
    provider_template=$(cat <<EOT
provider "azurerm" {
  subscription_id = "$1"
  client_id       = "$2"
  client_secret   = "$3"
  tenant_id       = "$4"
  features {}
}
EOT
    )
    echo "$provider_template" > $PROVIDER_FILE
}

function generateBackendFile {
    backend_template=$(cat <<EOT
terraform {
  backend "azurerm" {
    storage_account_name = "$TFSTATE_STORAGE"
    container_name       = "$TFSTATE_CONTAINER"
    key                  = "${deploymentPath}/terraform.tfstate"
    access_key           = "${1}"
  }
}
EOT
    )
    echo "$backend_template" > $BACKEND_FILE
}

function terraformProcessing {
    echo "starting terraform process..."
    terraform get
    terraform init -reconfigure
    if [ "$action" == "build" ]; then
        terraform apply -auto-approve
    else
        terraform destroy -auto-approve
    fi

    generateBackendFile
    generateProviderFile
}


#
# Pipeline execute
#

if [ "$action" == "build" ]; then
    steps=$(jq -c .deployments[] $deploy_file)
else
    steps=$(jq -c .deployments[] $deploy_file | tac)
fi

for step in $steps
do
    # extract data from pipeline
    export deploymentId=$(echo $step | jq -r '.deploymentId')
    export deploymentType=$(echo $step | jq -r '.deploymentType')
    export deploymentPath=$(echo $step | jq -r '.deploymentPath')
    export deploymentScope=$(echo $step | jq -r '.deploymentScope')
    export deploy=$(echo $step | jq -r '.deploy')

    # check value of deploy variable (set true as default)
    if [ "$deploy" != "true" ] && [ "$deploy" != "false" ]; then deploy="true"; fi

    echo ""
    echo "   #"
    echo "   # Step #${deploymentId}"
    echo "   #"
    echo "   # type: ${deploymentType}"
    echo "   # path: ${deploymentPath}"
    echo "   #"
    echo ""

    if $deploy; then
        case $deploymentType in
            terraform)
                export ENV=$(echo $deploymentPath | awk -F/ '{print $(NF-2)}')
                export LOCATION=$(echo $deploymentPath | awk -F/ '{print $(NF-1)}')

                # build process...
                cd ${ENV_DIR}/${deploymentPath}

                # terraform prepare
                terraformPrepare

                # start build script
                terraformProcessing
                ;;
            *)
                echo "WARN: deployment type ${deploymentType} not supported!"
                ;;
        esac

        # return to working dir
        cd $SCRIPT_DIR
    else
        echo "skipping ${deploymentType} deployment (${deploymentPath})"
    fi
done

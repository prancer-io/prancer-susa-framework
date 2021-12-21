#!/bin/bash
set -e

#
# Usage
#

if [ $# -lt 2 ]; then
    echo "Usage:" >&2
    echo "  Provide cloud and absololute or relative path to deploy dir." >&2
    echo "  $0 azure|aws|gcp ../parameters/azure/sub1/pipeline.json [--destroy|--plan]" >&2
    exit 1
fi

#
# Check required arguments
#

if [[ "$1" =~ ^(azure|aws|gcp)$ ]]; then
    cloud="$1"
    shift
else
    cloud="$1"
    echo "UNKNOWN cloud provider: ${cloud}, aborting..."
    exit 3
fi

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
        --plan)
            export action="plan"
            ;;
        --prepare)
            export action="prepare"
            ;;
        --destroy)
            export action="destroy"
            ;;
    esac
done

#
# Export variables
#

export SCRIPT_APATH=$(echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")")
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export PROVIDER_FILE="provider.tf"
export BACKEND_FILE="backend.tf"
export COMMON_REPO=$(cd $"$SCRIPT_DIR/../" && pwd)
export REPO_DIR=$(cd $(echo "$SCRIPT_APATH" | awk -F'/parameters/' '{print $1}') && pwd)
export ENV_DIR="$REPO_DIR/env"
export TPL_DIR="$ENV_DIR/provisioners"
export PARAM_DIR=$(cd ${deploy_file%/*} && pwd)
export PARAM_FILE="$PARAM_DIR/base.json"

# Debugging:
#echo "SCRIPT_DIR = $SCRIPT_DIR"
#echo "PROVIDER_FILE = $PROVIDER_FILE"
#echo "BACKEND_FILE = $BACKEND_FILE"
#echo "REPO_DIR = $REPO_DIR"
#echo "ENV_DIR = $ENV_DIR"
#echo "TPL_DIR = $TPL_DIR"
#echo "PARAM_DIR = $PARAM_DIR"
#echo "PARAM_FILE = $PARAM_FILE"

#
# Extract params
#

if [ -f "$PARAM_FILE" ]; then
    if [ "$cloud" == "azure" ]; then
        export TFSTATE_RG=$(jq -r .parameters.terraformSettings.value.name.resourceGroup $PARAM_FILE)
        export TFSTATE_STORAGE=$(jq -r .parameters.terraformSettings.value.name.storage $PARAM_FILE)
        export TFSTATE_CONTAINER="states"
        export SUB_ID=$(jq -r .parameters.configurationSettings.value.name.subscriptionId $PARAM_FILE)
        export CLIENT_ID=$(jq -r .parameters.terraformSettings.value.name.id $PARAM_FILE)
        export NAME=$(jq -r .parameters.terraformSettings.value.name.spn $PARAM_FILE)
        export VAULT=$(jq -r .parameters.terraformSettings.value.name.vault $PARAM_FILE)
    elif [ "$cloud" == "aws" ]; then
        export TFSTATE_STORAGE=$(jq -r .parameters.terraformSettings.value.name.bucket_name $PARAM_FILE)
        export TFSTATE_REGION=$(jq -r .parameters.terraformSettings.value.name.bucket_region $PARAM_FILE)
        export DEFAULT_REGION=$(jq -r .parameters.configurationSettings.value.name.defaultLocation $PARAM_FILE)
    fi
else
    echo "ERROR: Parameters not defined in $PARAM_FILE"
    exit 1
fi

if [ "$cloud" == "azure" ]; then
    #change the subscription to the current one
    if [ "$action" != "prepare" ]; then
        az account set -s $SUB_ID
    fi
fi
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
    if [ "$cloud" == "azure" ]; then
        if [ "$action" == "prepare" ]; then
            kv_key=""
            client_secret=""
            tenant_id=""
            SUB_ID=""
            CLIENT_ID=""
        else
            kv_key=$(getKeyvaultKey $TFSTATE_STORAGE $TFSTATE_RG)
            client_secret=$(getClientSecret "$NAME" "$VAULT")
            tenant_id=$(getTenantId)
        fi
    fi

    if [[ ! -f "./main.tf" ]]; then
        if [[ "$deploymentTemplate" == "null" || -z "$deploymentTemplate" ]]; then
            path="$TPL_DIR/${deploymentPath#*/*/}"
        else
            path="$TPL_DIR/${deploymentTemplate}"
        fi

        if [ -d "$path" ]; then
            for f in $(find "$path" -mindepth 1 -maxdepth 1)
            do
                if [[ -f "${f##*/}" || -L "${f##*/}" ]]; then
                    continue
                fi
                ln -s $f
            done
        else
            echo "ERROR: template path $TPL_DIR/${deploymentPath#*/} missing!"
            exit 1
        fi
    fi

    if [ "$cloud" == "azure" ]; then
        generateAzureBackendFile "$kv_key"
        generateAzureProviderFile "$SUB_ID" "$CLIENT_ID" "$client_secret" "$tenant_id"
    elif [ "$cloud" == "aws" ]; then
        generateAwsBackendFile
        generateAwsProviderFile
    elif [ "$cloud" == "gcp" ]; then
        generateGcpBackendFile
        generateGcpProviderFile
    fi
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

function generateAzureProviderFile {
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

function generateAzureBackendFile {
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

function generateAwsProviderFile {
    provider_template=$(cat <<EOT
provider "aws" {
  region                  = "$DEFAULT_REGION"
}
EOT
    )
    echo "$provider_template" > $PROVIDER_FILE
}

function generateAwsBackendFile {
    backend_template=$(cat <<EOT
terraform {
  backend "s3" {
    bucket = "$TFSTATE_STORAGE"
    key    = "${deploymentPath}/terraform.tfstate"
    region = "$TFSTATE_REGION"
  }
}
EOT
    )
    echo "$backend_template" > $BACKEND_FILE
}

function generateGcpProviderFile {
    provider_template=$(cat <<EOT
provider "google" {
  project     = "my-project-id"
  region      = "us-central1"
  zone        = "us-central1-c"
}
EOT
    )
    echo "$provider_template" > $PROVIDER_FILE
}

function generateGcpBackendFile {
    backend_template=$(cat <<EOT
terraform {
  backend "gcs" {
    bucket  = "$TFSTATE_STORAGE"
    prefix  = "${deploymentPath}/terraform.tfstate"
  }
}
EOT
    )
    echo "$backend_template" > $BACKEND_FILE
}

function remove_symlinks {
    for f in $(ls -1)
    do
        if [ -L "$f" ]; then
            unlink "$f"
        fi
    done
}

function terraformProcessing {
    if [ "$action" == "prepare" ]; then return; fi

    echo "starting terraform process..."
    terraform get
    terraform init -reconfigure
    if [ "$action" == "build" ]; then
        terraform apply -auto-approve
    elif [ "$action" == "plan" ]; then
        terraform plan
    else
        terraform destroy -auto-approve
    fi

    if [ "$cloud" == "azure" ]; then
        generateAzureBackendFile
        generateAzureProviderFile
    elif [ "$cloud" == "aws" ]; then
        generateAwsBackendFile
        generateAwsProviderFile
    fi
    remove_symlinks
}


#
# Pipeline execute
#

if [ "$action" == "destroy" ]; then
    steps=$(jq -c .deployments[] $deploy_file | tac)
else
    steps=$(jq -c .deployments[] $deploy_file)
fi

for step in $steps
do
    # extract data from pipeline
    export deploymentId=$(echo $step | jq -r '.deploymentId')
    export deploymentType=$(echo $step | jq -r '.deploymentType')
    export deploymentPath=$(echo $step | jq -r '.deploymentPath')
    export deploymentScope=$(echo $step | jq -r '.deploymentScope')
    export deploymentTemplate=$(echo $step | jq -r '.deploymentTemplate')
    export deploy=$(echo $step | jq -r '.deploy')

    # check value of deploy variable (set true as default)
    if [ "$deploy" != "true" ] && [ "$deploy" != "false" ]; then deploy="true"; fi

    echo ""
    echo "   #"
    echo "   # Stage #${deploymentId}"
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
            bash)
                if [[ "$action" == "destroy" || "$action" == "prepare" ]]; then
                    echo "      $action in progress, skipping..."
                    continue
                fi
                if [[ ! -f "${ENV_DIR}/${deploymentPath}" ]]; then
                    echo "ERROR: No such file ${ENV_DIR}/${deploymentPath}"
                    continue
                fi

                if [[ "$action" == "build" && "$deploymentScope" == "plan" ]]; then
                    echo "    skipping deployment ${deploymentPath} (included in PLAN scope)..."
                    continue
                fi
                if [[ "$action" == "plan" && "$deploymentScope" == "deploy" ]]; then
                    echo "    skipping deployment ${deploymentPath} (included in DEPLOY scope)..."
                    continue
                fi

                echo "      script ${ENV_DIR}/${deploymentPath} executing..."
                echo ""
                cd "$(dirname "${ENV_DIR}/${deploymentPath}")"
                bash "./$(basename "${ENV_DIR}/${deploymentPath}")"
                if [ $? -gt 0 ]; then
                    echo ""
                    echo "    # ERROR: bash script (${deploymentPath}) failed!"
                    echo "    # exiting..."
                    echo ""
                    exit 3
                fi
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

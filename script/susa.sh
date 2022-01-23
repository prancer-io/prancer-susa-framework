#!/bin/bash
set -e

#
# Usage
#

if [ $# -lt 2 ]; then
    echo "Usage:" >&2
    echo "  Provide cloud and absololute or relative path to deploy dir." >&2
    echo "  $0 azure|aws|gcp ../parameters/azure/sub1/pipeline.json [--destroy|--plan]" >&2
    echo "" >&2
    echo "  Setup initial pipeline configuration:" >&2
    echo "  $0 azure|aws|gcp --config" >&2
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

#
# Parse arguments
#

export prancer="disabled"
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
        --config|-config)
            export action="config"
            ;;
        --sca|-sca)
            export prancer="enabled"
            ;;
    esac
done

if [ -f "$1" ]; then
    deploy_file="$1"
else
    if [ "$action" != "config" ]; then
        echo "Pipeline file doesn't exists!"
        exit 1
    fi
fi

#
# Export variables
#

if [ "$action" == "config" ]; then
    export REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
    export ENV_DIR="$REPO_DIR/env"
    export PARAM_DIR="$REPO_DIR/parameters"
    export TPL_DIR="$ENV_DIR/provisioners"
    export PARAM_FILE="base.json"
    export LOG_FILE="/dev/null"
else
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
    export LOG_DIR="$REPO_DIR/log"
    export LOG_FILE="$REPO_DIR/log/$(date +%Y-%m-%d-%H-%M-%S).log"
fi

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
        export AWS_DEFAULT_REGION=$DEFAULT_REGION
    elif [ "$cloud" == "gcp" ]; then
        export PROJECT=$(jq -r .parameters.configurationSettings.value.name.project $PARAM_FILE)
        export TFSTATE_STORAGE=$(jq -r .parameters.terraformSettings.value.name.storage $PARAM_FILE)
        export DEFAULT_REGION=$(jq -r .parameters.configurationSettings.value.name.defaultRegion $PARAM_FILE)
        export GCP_DEFAULT_REGION=$DEFAULT_REGION
    fi
else
    if [ "$action" != "config" ]; then
        echo "ERROR: Parameters not defined in $PARAM_FILE"
        exit 1
    fi
fi

if [ "$cloud" == "azure" ]; then
    #change the subscription to the current one
    if [[ "$action" != "prepare" && "$action" != "config" ]]; then
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
  project     = "${PROJECT}"
  region      = "${DEFAULT_REGION}"
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

function configureCloud {
    case $1 in
        aws)
            read -p 'What is the account name? '           account_name
            read -p 'What is default region? [us-east-1] ' location
            read -p 'What is the S3 bucket name? '         s3_name
            read -p 'What is the S3 bucket region? '       s3_location

            account_name=$(echo "$account_name" | tr ' ' '-' | grep . || echo "undefined")
            location=$(echo "$location" | tr ' ' '-' | grep . || echo "us-east-1")
            s3_name=$(echo "$s3_name" | tr ' ' '-' | grep . || echo "undefined")
            s3_location=$(echo "$s3_location" | tr ' ' '-' | grep . || echo "undefined")

            suffix=$(date | md5sum | cut -c 1-8)
            echo "  initializing parameters..."
            param_dir="${REPO_DIR}/parameters/${cloud}/sub-${suffix}"
            mkdir -p "${param_dir}"
            cp "${REPO_DIR}/script/base.aws.tpl.json" "${param_dir}/${PARAM_FILE}"
            cp "${REPO_DIR}/script/pipeline.aws.tpl.json" "${param_dir}/pipeline.json"

            sed -i "s|%%account_name%%|${account_name}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%location%%|${location}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%bucket_name%%|${s3_name}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%bucket_region%%|${s3_location}|g" "${param_dir}/${PARAM_FILE}"

            sed -i "s|%%suffix%%|${suffix}|g" "${param_dir}/pipeline.json"
            sed -i "s|%%region%%|${location}|g" "${param_dir}/pipeline.json"

            echo "  initializing environment..."
            env_dir="${ENV_DIR}/${cloud}/sub-${suffix}/${location}/app-${suffix}/s3"
            mkdir -p "${env_dir}"
            cp "${REPO_DIR}/script/terraform.aws.tpl.tfvars" "${env_dir}/terraform.tfvars"

            sed -i "s|%%suffix%%|${suffix}|g" "${env_dir}/terraform.tfvars"

            echo "  Setup completed successfully! Run pipeline with:"
            echo "    bash script/susa.sh aws ${param_dir}/pipeline.json --plan"
            echo "    bash script/susa.sh aws ${param_dir}/pipeline.json"
            ;;
        azure)
            read -p 'What is the subscription name? '    subs_name
            read -p 'What is the subscription id? '      subs_id
            read -p 'What is the location? [centralus] ' location
            read -p 'What is the resource group name? '  rg_name
            read -p 'What is the keyvault name? '        kv_name
            read -p 'What is the SPN name? '             spn_name
            read -p 'What is the SPN id? '               spn_id
            read -p 'What is the storage name? '         storage_name

            subs_name=$(
                echo "$subs_name" | tr ' ' '-' | grep -oP "[a-zA-Z0-9\-_\.]" | \
                    xargs | tr -d ' ' | grep . || echo "undefined"
            )
            subs_id=$(
                echo "$subs_id" | \
                (grep -oP "[a-fA-F0-9\-]+" || echo "missconfigured") | head -1
            )
            location=$(echo "$location" | tr ' ' '-' | grep . || echo "centralus")
            rg_name=$(echo "$rg_name" | tr ' ' '-' | grep . || echo "undefined")
            kv_name=$(echo "$kv_name" | tr ' ' '-' | grep . || echo "undefined")
            spn_name=$(echo "$spn_name" | tr ' ' '-' | grep . || echo "undefined")
            spn_id=$(echo "$spn_id" | tr ' ' '-' | grep . || echo "undefined")
            storage_name=$(echo "$storage_name" | tr ' ' '-' | grep . || echo "undefined")

            suffix=$(date | md5sum | cut -c 1-8)
            echo "  initializing parameters..."
            param_dir="${REPO_DIR}/parameters/${cloud}/sub-${suffix}"
            mkdir -p "${param_dir}"
            cp "${REPO_DIR}/script/base.azure.tpl.json" "${param_dir}/${PARAM_FILE}"
            cp "${REPO_DIR}/script/pipeline.azure.tpl.json" "${param_dir}/pipeline.json"

            sed -i "s|%%subs_name%%|${subs_name}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%subs_id%%|${subs_id}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%location%%|${location}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%rg_name%%|${rg_name}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%kv_name%%|${kv_name}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%spn_name%%|${spn_name}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%spn_id%%|${spn_id}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%storage_name%%|${storage_name}|g" "${param_dir}/${PARAM_FILE}"

            sed -i "s|%%suffix%%|${suffix}|g" "${param_dir}/pipeline.json"
            sed -i "s|%%location%%|${location}|g" "${param_dir}/pipeline.json"

            echo "  initializing environment..."
            env_dir="${ENV_DIR}/${cloud}/sub-${suffix}/${location}/app-${suffix}/resource_group"
            mkdir -p "${env_dir}"
            cp "${REPO_DIR}/script/terraform.azure.tpl.tfvars" "${env_dir}/terraform.tfvars"

            sed -i "s|%%suffix%%|${suffix}|g" "${env_dir}/terraform.tfvars"
            sed -i "s|%%location%%|${location}|g" "${env_dir}/terraform.tfvars"

            echo "  Setup completed successfully! Run pipeline with:"
            echo "    bash script/susa.sh azure ${param_dir}/pipeline.json --plan"
            echo "    bash script/susa.sh azure ${param_dir}/pipeline.json"
            ;;
        gcp)
            read -p 'What is the GCP project ID? '        project_id
            read -p 'What is default region? [us-east1] ' location
            read -p 'What is the GCP bucket name? '       bucket_name

            project_id=$(echo "$project_id" | tr ' ' '-' | grep . || echo "undefined")
            location=$(echo "$location" | tr ' ' '-' | grep . || echo "us-east1")
            bucket_name=$(echo "$bucket_name" | tr ' ' '-' | grep . || echo "undefined")

            suffix=$(date | md5sum | cut -c 1-8)
            echo "  initializing parameters..."
            param_dir="${REPO_DIR}/parameters/${cloud}/sub-${suffix}"
            mkdir -p "${param_dir}"
            cp "${REPO_DIR}/script/base.gcp.tpl.json" "${param_dir}/${PARAM_FILE}"
            cp "${REPO_DIR}/script/pipeline.gcp.tpl.json" "${param_dir}/pipeline.json"

            sed -i "s|%%project_id%%|${project_id}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%location%%|${location}|g" "${param_dir}/${PARAM_FILE}"
            sed -i "s|%%bucket_name%%|${bucket_name}|g" "${param_dir}/${PARAM_FILE}"

            sed -i "s|%%suffix%%|${suffix}|g" "${param_dir}/pipeline.json"
            sed -i "s|%%region%%|${location}|g" "${param_dir}/pipeline.json"

            echo "  initializing environment..."
            env_dir="${ENV_DIR}/${cloud}/sub-${suffix}/${location}/app-${suffix}/vpc"
            mkdir -p "${env_dir}"
            cp "${REPO_DIR}/script/terraform.gcp.tpl.tfvars" "${env_dir}/terraform.tfvars"

            sed -i "s|%%project_id%%|${project_id}|g" "${env_dir}/terraform.tfvars"
            sed -i "s|%%suffix%%|${suffix}|g" "${env_dir}/terraform.tfvars"

            echo "  Setup completed successfully! Run pipeline with:"
            echo "    bash script/susa.sh gcp ${param_dir}/pipeline.json --plan"
            echo "    bash script/susa.sh gcp ${param_dir}/pipeline.json"
            ;;
        *)
            echo "Cloud: Unknown"
            ;;
    esac
}

#
# Pipeline execute
#

{

if [ "$action" == "config" ]; then
    configureCloud "$cloud"
    exit 0
fi

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

if [[ "$prancer" == "enabled" && "$action" == "build" ]];then
    if command -v prancer > /dev/null; then
        prancer --help
    else
        echo "WARN: prancer is enabled but not installed!"
    fi
fi

} | tee -a "$LOG_FILE"

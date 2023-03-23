#!/bin/bash -e

if [ -z "${ARM_STORAGE_ACCOUNT}" ]
then
  echo 'You should export a unique ARM_STORAGE_ACCOUNT'
fi

# Use environment variables or define defaults
if [ -z "${ARM_RESOURCE_GROUP}" ]
then
  export ARM_RESOURCE_GROUP=${USER}resourcegroup
fi

if [ -z "${ARM_LOCATION}" ]
then
  export ARM_LOCATION=westeurope
fi

# Open browser authentication
az login

# Store meta data
az account list > ~/.azure.json
chmod 600 ~/.azure.json

# Parse meta data
I=$(echo "$(jq .[].name < ~/.azure.json|grep -n Pay|cut -d: -f1)-1"|bc)
export I
ARM_SUBSCRIPTION_ID=$(az account list|jq -r .["${I}"].id)
echo ARM_SUBSCRIPTION_ID
export ARM_SUBSCRIPTION_ID
# Use the tenant in the Pay-as-you-go subscription
ARM_TENANT_ID=$(jq -r < ~/.azure.json .["${I}"].tenantId)
export ARM_TENANT_ID
# Set subscription to the paid subscription
az account set --subscription "${ARM_SUBSCRIPTION_ID}"
#az account show

# Create service-principal for Packer
az ad sp create-for-rbac -n "http://Packer" --role contributor \
	--scopes "/subscriptions/${ARM_SUBSCRIPTION_ID}" \
	> ~/.packer.json
chmod 600 ~/.packer.json

# Create file with environment variables for packer and ansible
echo > ~/.azure.rc && chmod 600  ~/.azure.rc
{
  echo "export ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID}"
  echo "export ARM_RESOURCE_GROUP=${ARM_RESOURCE_GROUP}"
  echo "export ARM_STORAGE_ACCOUNT=${ARM_STORAGE_ACCOUNT}"
  echo "export ARM_TENANT_ID=${ARM_TENANT_ID}"
  echo "export ARM_LOCATION=${ARM_LOCATION}"
  echo "export ARM_CLIENT_ID=$(jq -r .appId < ~/.packer.json)"
  echo "export ARM_CLIENT_SECRET=$(jq -r .password < ~/.packer.json)"
} >> ~/.azure.rc

# Create file with credentials for ansible
mkdir -p ~/.azure
cat > ~/.azure/credentials << EOF
[defaults]
subscription_id=${ARM_SUBSCRIPTION_ID}
client_id=${ARM_CLIENT_ID}
secret=${ARM_CLIENT_SECRET}
tenant=${ARM_TENANT_ID}
EOF


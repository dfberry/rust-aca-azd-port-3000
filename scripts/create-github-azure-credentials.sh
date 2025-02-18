#!/bin/bash
# filepath: /workspaces/rust-aca-azd-port-3000/scripts/create-github-azure-credentials.sh

## Prerequisites
## az login --use-device-code
## gh auth login
##

set -euo pipefail

# Check if the user is logged in to Azure CLI.
if ! az account show >/dev/null 2>&1; then
  echo "Error: You must be logged in to Azure CLI. Run 'az login' to continue."
  exit 1
fi

# Check if the user is logged in to GitHub CLI.
if ! gh auth status >/dev/null 2>&1; then
  echo "Error: You must be logged in to GitHub CLI. Run 'gh auth login' to continue."
  exit 1
fi

# Path to .env file
DOTENV_PATH=".env"

# Load environment variables from .env file into the script's environment
if [ -f "$DOTENV_PATH" ]; then
  set -a
  source "$DOTENV_PATH"
  set +a
else
  echo "Error: .env file not found at $DOTENV_PATH"
  exit 1
fi

# Create the service principal and capture its JSON output.
sp_output=$(az ad sp create-for-rbac \
  --name "$AZURE_CONTAINER_APP_NAME" \
  --role Contributor \
  --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP_NAME" \
  --output json)

# Retrieve the Azure Container Registry login URL.
acr_login=$(az acr show --name "$AZURE_CONTAINER_REGISTRY_NAME" --query "loginServer" --output tsv)

# Retrieve the ACR credentials (username and password).
acr_creds=$(az acr credential show --name "$AZURE_CONTAINER_REGISTRY_NAME" --output json)
acr_username=$(echo "$acr_creds" | jq -r '.username')
acr_password=$(echo "$acr_creds" | jq -r '.passwords[0].value')

# Compose the final JSON output with the required keys.
final_output=$(echo "$sp_output" | jq --arg subId "$AZURE_SUBSCRIPTION_ID" \
                                        --arg acrLogin "$acr_login" \
                                        --arg acrUsername "$acr_username" \
                                        --arg acrPassword "$acr_password" '{
  clientSecret: .password,
  subscriptionId: $subId,
  tenantId: .tenant,
  clientId: .appId,
  acrLoginUrl: $acrLogin,
  acrUsername: $acrUsername,
  acrPassword: $acrPassword
}')

echo "$final_output"

echo "IMPORTANT: Store the following as individual GitHub repo secrets:"
echo "- AZURE_CREDENTIALS (contains clientSecret, subscriptionId, tenantId, clientId)"
echo "- AZURE_CONTAINER_REGISTRY_NAME_LOGIN_SERVER"
echo "- AZURE_CONTAINER_REGISTRY_NAME_USERNAME"
echo "- AZURE_CONTAINER_REGISTRY_NAME_PASSWORD"

# Set the secrets using GitHub CLI for deployment.
gh secret set AZURE_CREDENTIALS -b"$final_output"
gh secret set AZURE_CONTAINER_REGISTRY_NAME_LOGIN_SERVER -b"$acr_login"
gh secret set AZURE_CONTAINER_REGISTRY_NAME_USERNAME -b"$acr_username"
gh secret set AZURE_CONTAINER_REGISTRY_NAME_PASSWORD -b"$acr_password"
gh secret set AZURE_CONTAINER_APP_NAME -b"$AZURE_CONTAINER_APP_NAME"
gh secret set AZURE_RESOURCE_GROUP_NAME -b"$AZURE_RESOURCE_GROUP_NAME"
gh secret set AZURE_CONTAINER_REGISTRY_NAME -b"$AZURE_CONTAINER_REGISTRY_NAME"
gh secret set IMAGE_NAME -b"rust-server"

echo "Secrets have been set successfully."
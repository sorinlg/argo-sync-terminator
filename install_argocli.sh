#!/usr/bin/env bash

set -e

# Ensure ARGOCD_VERSION is set
if [[ -z "${ARGOCD_VERSION}" ]]; then
  echo "ARGOCD_VERSION is not set"
  exit 1
fi

# Variables
ARGOCD_VERSION="v2.12.2"
BINARY_NAME="argocd"
DOWNLOAD_URL="https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
LOCAL_FOLDER="/usr/local/bin"
LOCAL_BINARY_PATH="${LOCAL_FOLDER}/${BINARY_NAME}"

# Create a local folder to store the binary
mkdir -p $LOCAL_FOLDER

# Download the ArgoCD binary
echo "Downloading ArgoCD version $ARGOCD_VERSION..."
curl -sSL $DOWNLOAD_URL -o $LOCAL_BINARY_PATH

# Make the binary executable
chmod +x $LOCAL_BINARY_PATH

# alias argocd to the local binary
alias argocd=$LOCAL_BINARY_PATH

# Run the ArgoCD binary from the local folder
echo "Checking ArgoCD binary from $LOCAL_BINARY_PATH..."
argocd version --client

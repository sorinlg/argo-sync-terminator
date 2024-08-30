#!/usr/bin/env bash

set -e

# This script is used to unblock ArgoCD Applications that are stuck in a Sync Status which requires manual intervention

# ensure ARGOCD_AUTH_TOKEN is set
if [[ -z "${ARGOCD_AUTH_TOKEN}" ]]; then
  echo "ARGOCD_AUTH_TOKEN is not set"
  exit 1
fi

# ensure ARGOCD_SERVER is set
if [[ -z "${ARGOCD_SERVER}" ]]; then
  echo "ARGOCD_SERVER is not set"
  exit 1
fi

# ensure APPLICATION_NAME is set
if [[ -z "${APPLICATION_NAME}" ]]; then
  echo "APPLICATION_NAME is not set"
  exit 1
fi

# Print operation context
echo ""
echo "====================================================="
echo ":: Sync Terminator :: Operation Context"
echo "ARGOCD_SERVER: ${ARGOCD_SERVER}"
echo "APPLICATION_NAME: "${APPLICATION_NAME}""
echo "====================================================="

# Show the current sync status
echo ""
echo "====================================================="
echo ":: Sync Terminator :: Current Sync Status"
operationStatePhase=$(argocd app get "${APPLICATION_NAME}" --show-operation --refresh -o json | jq -r '.status.operationState.phase')
echo "Current Operation State Phase: ${operationStatePhase}"
echo "====================================================="

# Terminate the current operation
## Only proceed if the current operation is in progress
if [[ "${operationStatePhase}" == "Running" ]]; then
  echo ""
  echo "====================================================="
  echo ":: Sync Terminator :: Terminating Current Operation"
  argocd app terminate-op "${APPLICATION_NAME}" \
    && echo "Operation terminated successfully"
  echo "====================================================="

  # Show the current sync status
  echo ""
  echo "====================================================="
  echo ":: Sync Terminator :: Refresh Sync Status"
  operationStatePhase=$(argocd app get "${APPLICATION_NAME}" --show-operation --refresh -o json | jq -r '.status.operationState.phase')
  echo "Current Operation State Phase: ${operationStatePhase}"
  echo "====================================================="
fi

## Only try to sync the application if the new operation status is not in progress
if [[ "${operationStatePhase}" != "Running" ]]; then
  # Sync the application
  echo ""
  echo "====================================================="
  echo ":: Sync Terminator :: Syncing Application"
  argocd app sync "${APPLICATION_NAME}" --prune --async --apply-out-of-sync-only --server-side \
    && echo "Application synced successfully"
  echo "====================================================="

  # Show the current sync status
  echo ""
  echo "====================================================="
  echo ":: Sync Terminator :: Refresh Sync Status"
  operationStatePhase=$(argocd app get "${APPLICATION_NAME}" --show-operation --refresh -o json | jq -r '.status.operationState.phase')
  echo "Current Operation State Phase: ${operationStatePhase}"
  echo "====================================================="
fi

# Show the new sync status
echo ""
echo "====================================================="
echo ":: Sync Terminator :: Get Application Details"
argocd app get "${APPLICATION_NAME}" --show-operation --refresh
echo "====================================================="

#!/bin/bash
set -euo pipefail

token="${VAULT_TOKEN:-}"
if [[ -z "${token}" ]] ; then
    echo "🛑 VAULT_TOKEN not set" 1>&2
    exit 15
fi

echo "ℹ️ Obtaining Artifactory credentials from Vault"

vault_result="$(
  curl --fail --show-error --silent \
       -X PUT -d 'null' \
       -H "X-Vault-Request: true" \
       -H "X-Vault-Token: ${token}" \
       https://vault.security-prod.reecenet.org/v1/artifactory/token/common-pipeline
)"

echo "ℹ️ Parsing Artifactory credentials from Vault response"

username="$(echo "${vault_result}" | jq -r .data.username)"
password="$(echo "${vault_result}" | jq -r .data.access_token)"

echo "ℹ️ Successfully obtained Artifactory credentials from Vault"

echo "::set-output name=username::${username}"
echo "::set-output name=password::${password}"

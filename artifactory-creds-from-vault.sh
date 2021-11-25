#!/bin/bash
set -euo pipefail

input_error='false'

token="${token:-}"
if [[ -z "${token}" ]] ; then
    echo "🛑 Input 'token' not provided" 1>&2
    input_error='true'
fi

url="${url:-}"
if [[ -z "${url}" ]] ; then
    echo "🛑 Input 'url' not provided" 1>&2
    input_error='true'
fi

path="${path:-}"
if [[ -z "${path}" ]] ; then
    echo "🛑 Input 'path' not provided" 1>&2
    input_error='true'
fi

if [[ "${input_error}" == 'true' ]] ; then
    exit 15
fi

echo "::group::🔓 Obtaining Artifactory credentials from Vault"

vault_result="$(
  curl --fail --show-error --silent \
       -X PUT -d 'null' \
       -H "X-Vault-Request: true" \
       -H "X-Vault-Token: ${token}" \
       "${url}/v1/${path}"
)"

echo "ℹ️ Parsing Artifactory credentials from Vault response"

username="$(echo "${vault_result}" | jq -r .data.username)"
password="$(echo "${vault_result}" | jq -r .data.access_token)"

echo "ℹ️ Successfully obtained Artifactory credentials from Vault"
echo "::endgroup::"

echo "::set-output name=username::${username}"
echo "::set-output name=password::${password}"

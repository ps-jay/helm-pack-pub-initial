#!/bin/bash
set -euo pipefail

env_error='false'

vars="""
    ARTIFACTORY_CREDS_PATH
    ARTIFACTORY_PRODUCTION
    BARNACLE_REGION
    BARNACLE_ROLE
    STASH_AD_CREDS_PATH
    STASH_PRODUCTION
    VAULT_PRODUCTION
"""

for var in ${vars} ; do
    if [[ -z "${!var:-}" ]] ; then
        echo "🛑 Environment variable '${var}' not set" 1>&2
        env_error='true'
    else
        echo "::set-output name=${var,,}::${!var}"
    fi
done

if [[ "${env_error}" == 'true' ]] ; then
    exit 63
fi

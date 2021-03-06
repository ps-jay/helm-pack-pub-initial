#!/bin/bash
set -euo pipefail

input_error='false'

chart="${chart:-}"
if [[ -z "${chart}" ]] ; then
    echo "đ Input 'chart' not provided" 1>&2
    input_error='true'
fi

version="${version:-}"
if [[ -z "${version}" ]] ; then
    echo "đ Input 'version' not provided" 1>&2
    input_error='true'
fi

username="${username:-}"
if [[ -z "${username}" ]] ; then
    echo "đ Artifactory 'username' not provided" 1>&2
    input_error='true'
fi

password="${password:-}"
if [[ -z "${password}" ]] ; then
    echo "đ Artifactory 'password' not provided" 1>&2
    input_error='true'
fi

if [[ "${input_error}" == 'true' ]] ; then
    exit 11
fi

# Determine Artifactory repository name
repository='helm-local'
if [[ ! "${version}" =~ '-' ]] ; then
    # version does not have a `-` character, must be a _stable_ version
    repository='helm-local-stable'
fi

echo "âšī¸ Publishing Helm chart '${chart}' to Artifactory repository '${repository}'"

checksum="$(md5sum "${chart}" | cut -d ' ' -f 1)"
curl --fail --show-error --silent \
     -H "X-Checksum-MD5:${checksum}" \
     -u "${username}:${password}" \
     -T "${chart}" \
     "https://artifactory.reecenet.org/artifactory/${repository}/${chart}"
echo ""

echo "âšī¸ Successfully published Helm chart '${chart}' to Artifactory repository '${repository}'"

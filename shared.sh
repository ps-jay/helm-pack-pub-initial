#!/bin/bash
# shellcheck disable=SC2034
set -euo pipefail

##==----------------------------------------------------------------------------
##  Input validation

input_error='false'

name="${name:-}"
if [[ -z "${name}" ]] ; then
    echo "🛑 Input 'name' not provided" 1>&2
    input_error='true'
fi

version="${version:-}"
if [[ -z "${version}" ]] ; then
    echo "🛑 Input 'version' not provided" 1>&2
    input_error='true'
fi

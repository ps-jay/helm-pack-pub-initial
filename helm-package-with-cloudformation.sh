#!/bin/bash
set -euo pipefail

helm_version='3.7.1'
helm_image="alpine/helm:${helm_version}"
docker_proxy="${INPUT_DOCKER_PROXY:-}"

input_error='false'

name="${INPUT_NAME:-}"
if [[ -z "${name}" ]] ; then
    echo "🛑 Input 'name' not provided" 1>&2
    input_error='true'
fi

version="${INPUT_VERSION:-}"
if [[ -z "${version}" ]] ; then
    echo "🛑 Input 'version' not provided" 1>&2
    input_error='true'
fi

if [[ "${input_error}" == 'true' ]] ; then
    exit 11
fi

chart_dir="${INPUT_CHART_DIR:-helm/${name}}"
if [[ ! -d "${chart_dir}" ]] ; then
    echo "🛑 Chart directory '${chart_dir}' not found" 1>&2
    exit 13
fi

cloudformation_dir="${INPUT_CLOUDFORMATION_DIR:-cloudformation}"
if [[ -d "${cloudformation_dir}" ]] ; then
    echo "ℹ️ Cloudformation directory '${cloudformation_dir}' found, will package within the Helm chart tgz file"
    ln -sf "../../${cloudformation_dir}" "${chart_dir}/cloudformation"
fi

# Skip if testing (avoids multiple unneccessary docker pulls - speed up)
if [[ -z "${BATS_VERSION:-}" ]] ; then
    echo "ℹ️ Pulling Helm docker image '${docker_proxy}${helm_image}'"
    docker pull --quiet "${docker_proxy}${helm_image}"
fi

echo "ℹ️ Packaging Helm chart '${name}' version ${version}"
docker run --rm --user "$(id -u):$(id -g)" \
    --volume "$(pwd):/src" \
    --workdir /src \
    "${docker_proxy}${helm_image}" \
        package "${chart_dir}" \
            "--version=${version}" \
            "--app-version=${version}"

if [[ ! -f "${name}-${version}.tgz" ]] ; then
    chart_file="$(ls -b -- *"${version}".*)"
    echo "🛑 Name set in Chart.yaml '${chart_file//-${version}.tgz}' does not match the name input to this action '${name}'" 1>&2
    exit 15
fi

echo "ℹ️ Created Helm chart '${name}-${version}.tgz'"

echo "::set-output name=chart::${name}-${version}.tgz"

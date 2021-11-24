#!/bin/bash
set -euo pipefail

# https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# shellcheck source=shared.sh
source "${script_dir}/shared.sh"

if [[ "${input_error}" == 'true' ]] ; then
    exit 11
fi

helm_version="${helm_version:-3.7.1}"  # Update the default as newer versions are released
helm_image="alpine/helm:${helm_version}"
docker_proxy="${docker_proxy:-}"

chart_dir="${chart_dir:-helm/${name}}"
if [[ ! -d "${chart_dir}" ]] ; then
    echo "🛑 Chart directory '${chart_dir}' not found" 1>&2
    exit 13
fi

cloudformation_dir="${cloudformation_dir:-cloudformation}"
if [[ -n "${cloudformation_dir}" && -d "${cloudformation_dir}" ]] ; then
    echo "ℹ️ Cloudformation directory '${cloudformation_dir}' found, will package within the Helm chart tgz file"
    relative_path="$(realpath --relative-to="${chart_dir}" "${cloudformation_dir}")"
    ln -sf "${relative_path}" "${chart_dir}/cloudformation"
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

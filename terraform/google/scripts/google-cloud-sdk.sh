#!/bin/bash

[[ "$OSTYPE" =~ "linux" ]] && os=linux
[[ "$OSTYPE" =~ "darwin" ]] && os=darwin

[ -z $os ] && echo "$OSTYPE" is not supported && exit

dir=$(dirname "$0")
arch=$(uname -m)
cloud_sdk_version="204.0.0"
declare -A cloud_sdk_hashes=(
	["linux_x86_64"]="276984a44a2a9dc1af5d3c859a1295897fd8cfc911738874daf007ab46143da5"
	["darwin_x86_64"]="eaeea9babf8e6c2a66bf6db3a2ecb34fc24fc4b2858ab3f7660386c7c79177cf"
)
cloud_sdk_file="google-cloud-sdk-${cloud_sdk_version}-${os}-${arch}.tar.gz"
cloud_sdk_url="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${cloud_sdk_file}"
temp_dir="${dir}/../.tmp"
download_dir="${temp_dir}/downloads"
release_dir="${temp_dir}/releases/${cloud_sdk_version}"
gcloud="${release_dir}/google-cloud-sdk/bin/gcloud"

if [ ! -f "$gcloud" ]; then
	mkdir -p "${release_dir}"
	if [ ! -f "${download_dir}/${cloud_sdk_file}" ]; then
		mkdir -p "${download_dir}"
		wget "$cloud_sdk_url" -O "${download_dir}/${cloud_sdk_file}"
	fi
	cloud_sdk_hash="$(
		sha256sum "${download_dir}/${cloud_sdk_file}" | awk '{print $1}'
	)"
	echo "$cloud_sdk_hash"

	set -x
	[[ "${cloud_sdk_hashes[${os}_${arch}]}" == "$cloud_sdk_hash" ]] || \
		{ ( >&2 echo "Invalid hash for ${cloud_sdk_file}"); exit 1; }
	tar -xf "${download_dir}/${cloud_sdk_file}" -C "${release_dir}"
fi

echo "${release_dir}/google-cloud-sdk"


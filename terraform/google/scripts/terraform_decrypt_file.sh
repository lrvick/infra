#!/bin/bash
set -e

secret_file_in="$(jq '@sh "\(.file)"'| tr -d \'\")"
secret_file_out="$(mktemp -p /dev/shm/)"
chmod 600 "$secret_file_out"

gpg -d "$secret_file_in" > "$secret_file_out"

jq -r -n --arg file "$secret_file_out" '{"file":$file,}'

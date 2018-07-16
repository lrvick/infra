#!/bin/bash
set -e

secret_file_in="secrets/terraform-admin.json.asc"
secret_file_out="$(mktemp -p /dev/shm/)"
chmod 600 "$secret_file_out"

gpg -d "$secret_file_in" > "$secret_file_out"

echo "$secret_file_out"

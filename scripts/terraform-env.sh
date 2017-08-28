#!/bin/bash
# shellcheck disable=SC1091
# shellcheck disable=SC2001

action=$(echo "$1" | sed 's/-[a-z]\+//g')
account_name=$(echo "$1" | sed 's/[a-z]\+-//g')

export AWS_PROFILE="lrvick-root"

echo -n "MFA Token: "
read -r mfa_token

source scripts/aws-mfa.sh "$account_name" "$mfa_token"

cd "terraform/accounts/${account_name}" || { \
	echo "cd failed" && exit; \
}

terraform get
terraform "${action}"

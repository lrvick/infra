#!/bin/bash

unset AWS_SESSION_TOKEN
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

account_name="${1:-root}"
mfa_token="$2"
user_name=$(aws iam get-user | jq -r '.[] .UserName')
mfa_serial=$( \
	aws iam list-virtual-mfa-devices \
		| jq -r \
			".[] [] | select(.User.UserName==\"$user_name\") .SerialNumber" \
)
if [ "$account_name" != "root" ]; then
	organizations=$(aws organizations list-accounts | jq -r '.[]')
	account_id=$(
		echo "$organizations" \
			| jq -r ".[] | select(.Name==\"$account_name\") .Id" \
	)
fi

if [ "$account_name" == "root" ]; then
	credentials=$(\
		aws sts get-session-token \
			--serial-number "$mfa_serial" \
			--token-code "$mfa_token" \
		| jq -r '.[]' \
	)
else
	credentials=$( \
		aws sts assume-role \
			--serial-number "$mfa_serial" \
			--token-code "$mfa_token" \
			--role-session-name "$user_name" \
			--role-arn \
				"arn:aws:iam::$account_id:role/OrganizationAccountAccessRole" \
		| jq -r '.[]' \
	)
fi

AWS_SESSION_TOKEN="$(\
	printf "%s" "$credentials" | jq -r '.SessionToken'| head -n 1 \
)"
export AWS_SESSION_TOKEN
AWS_ACCESS_KEY_ID="$(\
	printf "%s" "$credentials" | jq -r '.AccessKeyId' | head -n 1 \
)"
export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY="$( \
	printf "%s" "$credentials" | jq -r '.SecretAccessKey' | head -n1 \
)"
export AWS_SECRET_ACCESS_KEY

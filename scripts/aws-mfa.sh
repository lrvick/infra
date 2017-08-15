#!/bin/bash

user_id=$(aws sts get-caller-identity | jq -r '.UserId')
mfa_serial=$( \
	aws iam list-virtual-mfa-devices \
		| jq -r ".[] [] | select(.User.UserId==\"$user_id\") .SerialNumber" \
)

echo -n "Please provide MFA token: "
read mfa_token
credentials=$(\
	aws sts get-session-token \
		--serial-number $mfa_serial \
		--token-code $mfa_token \
	| jq -r '.[]'
)

export AWS_SESSION_TOKEN=$(echo $credentials | jq -r '.SessionToken' )
export AWS_ACCESS_KEY_ID=$(echo $credentials | jq -r '.AccessKeyId' )
export AWS_SECRET_ACCESS_KEY=$(echo $credentials | jq -r '.SecretAccessKey' )

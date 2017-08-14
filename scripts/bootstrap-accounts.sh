#!/bin/bash
set -e

# Create CI/Environment Accounts
aws organizations create-account \
	--email aws-ci@lrvick.net \
	--account-name "ci"
aws organizations create-account \
	--email aws-production@lrvick.net \
	--account-name "production"
aws organizations create-account \
	--email aws-staging@lrvick.net \
	--account-name "staging"
aws organizations create-account \
	--email aws-development@lrvick.net \
	--account-name "development"

# Get account id by name
get_account_id(){
	aws organizations list-accounts \
		| jq -r ".[] [] | select(.Name == \"$1\").Id"
}

# Create CI Organizational Units
root_ou_id="$(aws organizations list-roots | jq -r '.Roots[].Id')"
ci_ou_id=$(\
	aws organizations create-organizational-unit \
		--parent-id "$root_ou_id" \
		--name "CI" \
	| jq -r '.[].Id' \
)
environments_ou_id=$(\
	aws organizations create-organizational-unit \
		--parent-id "$ci_ou_id" \
		--name "Environments" \
	| jq -r '.[].Id' \
)

# Attach Accounts to appropriate Organizational Units
aws organizations move-account \
	--account-id "$(get_account_id 'ci')" \
	--source-parent-id "$root_ou_id" \
	--destination-parent-id "$ci_ou_id"

aws organizations move-account \
	--account-id "$(get_account_id 'production')" \
	--source-parent-id "$root_ou_id" \
	--destination-parent-id "$environments_ou_id"

aws organizations move-account \
	--account-id "$(get_account_id 'staging')" \
	--source-parent-id "$root_ou_id" \
	--destination-parent-id "$environments_ou_id"

aws organizations move-account \
	--account-id "$(get_account_id 'development')" \
	--source-parent-id "$root_ou_id" \
	--destination-parent-id "$environments_ou_id"

# TODO
# Should create/attach account policies for IAM resource restrictions

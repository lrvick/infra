#!/bin/bash
set -e

accounts="ci production staging development"
basename="lrvick"
email_domain="lrvick.net"

aws cloudformation deploy \
	--template-file cloudformation/terraform-init.yml \
	--stack-name ${basename}-root \
	--capabilities CAPABILITY_NAMED_IAM

# Create CI/Environment Accounts
for account in $accounts; do
	echo "Creating Account: $account"
	create_request_id=$( \
		aws organizations create-account \
			--email aws-${account}@lrvick.net \
			--account-name "${account}" | jq -r '.[] .Id' \
	)
	while sleep 1; do
		create_status_response=$(\
			aws organizations describe-create-account-status \
				--create-account-request-id $create_request_id \
		)
		create_status=$(echo $create_status_response | jq -r '.[] .State')
		case "$create_status" in
			SUCCEEDED)
			  echo "Successfully created account: $account"
			  break;
			  ;;
			FAILED)
			  echo "Account creation failed: $account"
			  echo "Failure Reason: $( \
			  	echo $create_status_response | jq -r '.[] .FailureReason' \
			  )"
			  exit;
			  ;;
			IN_PROGRESS)
			  echo "Account creation in progress: $account"
			  ;;
		esac
	done
	aws cloudformation deploy \
		--template-file cloudformation/terraform-init.yml \
		--stack-name ${basename}-${account} \
		--capabilities CAPABILITY_NAMED_IAM
done

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

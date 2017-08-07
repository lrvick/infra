# lrvick's Infra

This repo is there I manage all of the live configuration for my personal
infrastructure.

While this is intended only for personal use, I attempt to provide abstractions
so any of these patterns or modules can be re-used as desired for a wide range
of personal or company needs.

Mostly I am documenting this for my future self, because that guy forgets
everything and needs every little detail laid out for him.

## Setup

### AWS Account Setup

This should be the only time root credentials for the master account are ever
required.

1. Create AWS Organization
  See: [http://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_create.html]

  Be sure and choose "Enable All Features"
2. Enable IAM managed billing
  a. Visit: [https://console.aws.amazon.com/billing/home?region=us-west-2#/account]
  b. Check "IAM user/role access to billing information"
3. Activate MFA on root account
  See: [http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa.html?icmpid=docs_iam_console]

  A touch-enabled hardware security module such as a Yubikey 4 is recommended
  to greatly limit risk of leaking TOTP secret.
4. Generate root Access Keys
  See: [http://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html?icmpid=docs_iam_console#id_root-user_manage_add-key]
5. Bootstrap organization accounts and global users/roles/policies
  ```
  make install
  ```
6. Delete root Access Keys
  See: [http://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html?icmpid=docs_iam_console#id_root-user_manage_add-key]

### AWS User Setup

Each user will need to do some one-time manual steps before using their
account.

1. Change account password
  See: [http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_user-change-own.html]
2. Generate access keys (Optional)
  See: [http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html]
3. Configure CLI with access keys (Optional)
  ```
  aws configure
  ```
4. Bind MFA device to account:
  ```
  aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name lrvick-yubikey \
    --bootstrap-method Base32StringSeed
  aws iam enable-mfa-device \
    --user-name lrvick \
    --serial-number arn:aws:iam::210987654321:mfa/lrvick-yubikey \
    --authentication-code-1 123456 \
    --authentication-code-2 789012
  ```

## Usage

Initialize a session token via your MFA device:

```
aws sts get-session-token \
  --serial-number arn-of-the-mfa-device \
  --token-code code-from-token
export AWS_SESSION_TOKEN=<Session-Token-as-in-Previous-Output>
```

Change terraform configuration as desired and apply changes with:

```
make apply
```

# lrvick's Infra

This repo is there I manage all of the live configuration for my personal
infrastructure.

While this is intended only for personal use, I attempt to provide abstractions
so any of these patterns or modules can be re-used as desired for others with
similar needs.

Mostly I am documenting this for my future self, because that guy forgets
everything and needs every little detail laid out for him.

## Setup

Do all required bootstrapping for new AWS account.

```
make bootstrap
```

This process will create users as defined in cloudformation/global.yml

Each user will need to do some manual steps before using their account:

1. Change password at [https://<account>.signin.aws.amazon.com]
2. Generate access keys
3. Configure CLI with access keys:
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

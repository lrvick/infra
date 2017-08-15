data "aws_caller_identity" "current" {}

resource "aws_iam_group" "admin" {
  name = "admin"
}

resource "aws_iam_group_membership" "admin" {
  name = "admin_group_membership",
  group = "${aws_iam_group.admin.name}"
  users = ["lrvick"]
}

resource "aws_iam_group_policy" "admin_access" {
  group = "${aws_iam_group.admin.id}"
  name = "administrator_access"
  policy = "${data.aws_iam_policy_document.admin_access.json}"
}

data "aws_iam_policy_document" "admin_access" {
  statement {
    effect = "Allow",
    actions = ["*"],
    resources = ["*"],
  }
}

resource "aws_iam_group" "billing" {
  name = "billing"
}

resource "aws_iam_group_membership" "billing" {
  name = "billing_group_membership",
  group = "${aws_iam_group.billing.name}"
  users = ["lrvick"]
}

resource "aws_iam_group_policy" "billing_access" {
  group = "${aws_iam_group.billing.id}"
  name = "billing_access"
  policy = "${data.aws_iam_policy_document.billing_access.json}"
}

data "aws_iam_policy_document" "billing_access" {
  statement {
    effect = "Allow"
    actions = [
      "aws-portal:*Billing",
      "aws-portal:*Usage",
      "aws-portal:*PaymentMethods",
      "budgets:ViewBudget",
      "budgets:ModifyBudget",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_group" "user" {
  name = "user"
}
resource "aws_iam_group_membership" "user" {
  name = "user_group_membership",
  group = "${aws_iam_group.user.name}"
  users = ["lrvick"]
}

resource "aws_iam_group_policy" "require_mfa" {
  group = "${aws_iam_group.user.id}"
  name = "require_mfa"
  policy = "${data.aws_iam_policy_document.require_mfa.json}"
}

data "aws_iam_policy_document" "require_mfa" {
  statement {
    sid = "AllowAllUsersToListAccounts"
    effect = "Allow"
    actions = [
      "iam:ListAccountAliases",
      "iam:GetAccountPasswordPolicy",
      "iam:ListUsers",
    ]
    resources = ["*"]
  }
  statement {
    sid = "AllowIndividualUserToSeeTheirAccountInformation"
    effect = "Allow"
    actions = [
      "iam:ChangePassword",
      "iam:CreateLoginProfile",
      "iam:DeleteLoginProfile",
      "iam:GetAccountSummary",
      "iam:GetLoginProfile",
      "iam:UpdateLoginProfile",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/&{aws:username}"
    ]
  }
  statement {
    sid = "AllowIndividualUserToListTheirMFA"
    effect = "Allow"
    actions = [
      "iam:ListVirtualMFADevices",
      "iam:ListMFADevices"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/&{aws:username}"
    ]
  }
  statement {
    sid = "AllowIndividualUserToManageThierMFA"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeactivateMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/&{aws:username}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/&{aws:username}"
    ]
  }
  statement {
    sid = "DenyEverythingExceptForBelowUnlessMFAd"
    effect = "Deny"
    not_actions = [
      "iam:ListVirtualMFADevices",
      "iam:ListMFADevices",
      "iam:ListUsers",
      "iam:ListAccountAliases",
      "iam:CreateVirtualMFADevice",
      "iam:DeactivateMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ChangePassword",
      "iam:CreateLoginProfile",
      "iam:DeleteLoginProfile",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:GetLoginProfile",
      "iam:UpdateLoginProfile",
    ]
    resources = ["*"]
    condition = {
      test = "Null"
      variable = "aws:MultiFactorAuthAge"
      values = ["true"]
    }
  }
  statement {
    sid = "DenyIamAccessToOtherAccountsUnlessMFAd"
    effect = "Deny"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeactivateMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ChangePassword",
      "iam:CreateLoginProfile",
      "iam:DeleteLoginProfile",
      "iam:GetAccountSummary",
      "iam:GetLoginProfile",
      "iam:UpdateLoginProfile",
    ]
    not_resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/&{aws:username}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/&{aws:username}"
    ]
    condition = {
      test = "Null"
      variable = "aws:MultiFactorAuthAge"
      values = ["true"]
    }
  }
}

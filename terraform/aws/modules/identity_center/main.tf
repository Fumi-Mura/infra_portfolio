data "aws_ssoadmin_instances" "this" {}

# 許可セットの作成
resource "aws_ssoadmin_permission_set" "this" {
  for_each = toset([
    "AdministratorAccess",
    "ReadOnlyAccess"
  ])
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  name             = each.value
  session_duration = "PT8H"
}

# 許可セットにpolicyをアタッチ
resource "aws_ssoadmin_managed_policy_attachment" "main" {
  for_each = aws_ssoadmin_permission_set.this

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/${each.key}"
  permission_set_arn = each.value.arn
}

# Create user
resource "aws_identitystore_user" "this" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  for_each = toset([
    "Admin",
    "ReadOnly"
  ])

  user_name    = each.key # signinに使用、後から変更不可
  display_name = each.key

  name {
    given_name  = each.key
    family_name = "user"
  }

  emails {
    value = "381704fumi+${var.env}-${each.key}@gmail.com"
  }
}

# Create group
resource "aws_identitystore_group" "this" {
  for_each = toset([
    "Admin",
    "ReadOnly"
  ])
  display_name      = "${var.env}-iam-identity-center-group-${each.key}"
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

# Attach user to group
resource "aws_identitystore_group_membership" "this" {
  for_each = aws_identitystore_user.this

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = aws_identitystore_group.this[each.key].group_id
  member_id         = aws_identitystore_user.this[each.key].user_id
}


# # 各アカウントにIAM Identity Center (SSO)の設定を適用
# resource "aws_ssoadmin_account_assignment" "assignments" {
#   for_each           = aws_organizations_account.accounts
#   instance_arn       = data.aws_ssoadmin_instances.this.arn
#   permission_set_arn = aws_ssoadmin_permission_set.this.arn
#   principal_id       = "user@example.com" # 設定するユーザーのID
#   principal_type     = "USER"
#   target_id          = each.value.id
#   target_type        = "AWS_ACCOUNT"
# }

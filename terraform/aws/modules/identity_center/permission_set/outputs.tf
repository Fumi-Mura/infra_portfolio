output "permission_set_arn" {
  value = aws_ssoadmin_permission_set.this["AdministratorAccess"].arn
}

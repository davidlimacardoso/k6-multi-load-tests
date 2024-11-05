output "secret" {
  description = "List of keys in the secret"
  value = {
    secret_name = "secret/${var.project}-${var.env}"
    keys        = var.secret_value.*.key
  }
}
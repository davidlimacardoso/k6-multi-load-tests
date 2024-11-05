resource "aws_secretsmanager_secret" "asm" {
  name = "secret/${var.project}-${var.env}"
}

resource "aws_secretsmanager_secret_version" "secret_value" {
  secret_id = aws_secretsmanager_secret.asm.id
  secret_string = jsonencode({
    for item in var.secret_value : item.key => item.value
  })
}
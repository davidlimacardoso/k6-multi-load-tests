resource "aws_route53_zone" "private" {

  name = var.private.name
  vpc {
    vpc_id = var.private.vpc_id
  }
}

resource "aws_route53_record" "internal" {
  for_each = { for i in var.private.records : i.name => i }
  zone_id  = aws_route53_zone.private.zone_id
  name     = "${each.value.name}.${var.private.name}"
  type     = each.value.type
  ttl      = each.value.ttl
  records  = each.value.records
}


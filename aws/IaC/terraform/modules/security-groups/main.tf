# Create Codebuild Security Group
resource "aws_security_group" "codebuild_sg" {
  name        = var.sg_ingress.codebuild-sg.name
  description = var.sg_ingress.codebuild-sg.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress.codebuild-sg.ingress
    content {
      description     = ingress.value.description
      protocol        = ingress.value.protocol
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      prefix_list_ids = lookup(ingress.value, "prefix_list_ids", null)
    }
  }

  egress {
    protocol    = "-1"
    from_port   = var.sg_egress.port
    to_port     = var.sg_egress.port
    cidr_blocks = var.sg_egress.cidr_blocks
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.sg_ingress.codebuild-sg.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create grafana instance security group
# Conditions ingress rules are allowing only:
#   - port 3000 from ELB
#   - port 22 from bastion host
#   - someone port to VPC CDIR 
resource "aws_security_group" "grafana_sg" {
  name        = var.sg_ingress.grafana-instance-sg.name
  description = var.sg_ingress.grafana-instance-sg.description
  vpc_id      = var.vpc_id
  depends_on  = [aws_security_group.bastion_sg, aws_security_group.elb_sg]
  dynamic "ingress" {
    for_each = var.sg_ingress.grafana-instance-sg.ingress
    content {
      description     = ingress.value.description
      protocol        = ingress.value.protocol
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = ingress.value.from_port == 22 ? [aws_security_group.bastion_sg.id] : ingress.value.from_port == 3000 ? [aws_security_group.elb_sg.id] : lookup(ingress.value, "security_groups", [])
      prefix_list_ids = lookup(ingress.value, "prefix_list_ids", null)
    }
  }

  egress {
    protocol    = "-1"
    from_port   = var.sg_egress.port
    to_port     = var.sg_egress.port
    cidr_blocks = var.sg_egress.cidr_blocks
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.sg_ingress.grafana-instance-sg.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name        = var.sg_ingress.bastion-sg.name
  description = var.sg_ingress.bastion-sg.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress.bastion-sg.ingress
    content {
      description     = ingress.value.description
      protocol        = ingress.value.protocol
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      prefix_list_ids = lookup(ingress.value, "prefix_list_ids", null)
    }
  }

  egress {
    protocol    = "-1"
    from_port   = var.sg_egress.port
    to_port     = var.sg_egress.port
    cidr_blocks = var.sg_egress.cidr_blocks
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.sg_ingress.bastion-sg.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create Load Balancer Security Group
resource "aws_security_group" "elb_sg" {
  name        = var.sg_ingress.elb-sg.name
  description = var.sg_ingress.elb-sg.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress.elb-sg.ingress
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      prefix_list_ids = lookup(ingress.value, "prefix_list_ids", null)
    }
  }

  egress {
    protocol    = "-1"
    from_port   = var.sg_egress.port
    to_port     = var.sg_egress.port
    cidr_blocks = var.sg_egress.cidr_blocks
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.sg_ingress.elb-sg.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
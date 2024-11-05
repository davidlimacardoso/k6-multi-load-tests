## Data codebuild service assume role
data "aws_iam_policy_document" "codebuild_service_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

## Data Codepipeline service assume role

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

##################################################################
## Role to Codebuild
##################################################################

## Codebuild service role
resource "aws_iam_role" "codebuild_service_role" {

  name               = "${var.project}-${var.env}-service-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_service_assume_role.json
  path               = "/"
  description        = "CodeBuild service role for ${var.project}-${var.env}"
}

## Codebuild service role policy attachment to get secrets in Secrets Manager
resource "aws_iam_role_policy" "inline_policy_codebuild_secrets" {
  name = "${var.project}-${var.env}-secrets-role-policy"
  role = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "GetSecret",
        "Effect" : "Allow",
        "Action" : "secretsmanager:GetSecretValue",
        "Resource" : "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${var.secrets_manager.secret_name}*"
      }
    ]
  })
}

## Codebuild service role policy attachment to allow access for EC2
resource "aws_iam_role_policy" "inline_policy_codebuild_ec2" {
  name = "${var.project}-${var.env}-ec2-role-policy"
  role = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DescribeVpcs",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "AllowEC2Network"
      },
      {
        "Action" : [
          "ec2:CreateNetworkInterfacePermission"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:AuthorizedService" : "codebuild.amazonaws.com"
          }
        },
        "Effect" : "Allow",
        "Resource" : "arn:aws:ec2:${local.region}:${local.account_id}:network-interface/*"
      }
    ],
    "Version" : "2012-10-17"
  })
}

## Codebuild service role policy attachment to allow access for EC2
resource "aws_iam_role_policy" "inline_policy_codebuild_logs" {
  name = "${var.project}-${var.env}-cw-role-policy"
  role = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogStream",
          "logs:GetLogRecord",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "VisualEditor0"
      }
    ],
    "Version" : "2012-10-17"
  })
}

## Codebuild service role policy attachment to allow access for EC2
resource "aws_iam_role_policy" "inline_policy_codebuild_s3" {
  name = "${var.project}-${var.env}-s3-role-policy"
  role = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "s3:GetObject"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${var.s3_artifact_bucket}",
          "arn:aws:s3:::${var.s3_artifact_bucket}/*"
        ]
        "Sid" : "GetArtifact"
      }
    ],
    "Version" : "2012-10-17"
  })
}

# ## Codebuild service role policy attachment to manager ECR and GIT images and commands
resource "aws_iam_role_policy" "inline_policy_codebuild_ecr" {
  name = "${var.project}-${var.env}-ecr-role-policy"
  role = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "ssm:GetParameters",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:UploadLayerPart",
          "ecr:ListImages",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:GetAuthorizationToken",
          "ecr:PutImage",
          "codestar-connections:UseConnection",
          "codecommit:GitPull"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "VisualEditor0"
      }
    ],
    "Version" : "2012-10-17"
  })
}

##################################################################
## Codebuild batch executations
##################################################################
resource "aws_iam_role" "codebuild_batch_role" {

  name               = "${var.project}-${var.env}-batch-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_service_assume_role.json
  path               = "/service-role/"
  description        = "CodeBuild batch role for ${var.project}-${var.env}"

}

resource "aws_iam_role_policy" "inline_policy_codebuild_batch_role" {
  name = "${var.project}-${var.env}-batch-build-policy"
  role = aws_iam_role.codebuild_batch_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:codebuild:${local.region}:${local.account_id}:project/${var.project}-${var.env}"
        ],
        "Action" : [
          "codebuild:StartBuild",
          "codebuild:StopBuild",
          "codebuild:RetryBuild"
        ]
      }
    ]
  })
}

##################################################################
## Data Codepipeline role to Git
##################################################################

resource "aws_iam_role" "codepipeline_git" {

  name               = "${var.project}-${var.env}-codepipeline-service-git"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  path               = "/"

}

resource "aws_iam_role_policy" "inline_role_codepipeline_git_policy" {
  name = "${var.project}-${var.env}-codepipeline-github-policy"
  role = aws_iam_role.codepipeline_git.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${var.s3_artifact_bucket}",
          "arn:aws:s3:::${var.s3_artifact_bucket}/*"
        ]
      },
      {
        "Action" : [
          "codebuild:BatchGetBuildBatches",
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StartBuildBatch"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "codestar-connections:*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:codeconnections:${local.region}:${local.account_id}:connection/${var.git_connection}"
      }
    ]
  })
}
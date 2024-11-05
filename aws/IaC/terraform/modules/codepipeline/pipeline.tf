resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project}-${var.env}"
  role_arn = aws_iam_role.codepipeline_git.arn

  artifact_store {
    location = var.s3_artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      namespace        = "SourceVariables"

      configuration = {
        ConnectionArn        = "arn:aws:codeconnections:${local.region}:${local.account_id}:connection/${var.git_connection}"
        FullRepositoryId     = var.git_repository
        DetectChanges        = false
        BranchName           = var.git_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name      = "Build"
      category  = "Build"
      owner     = "AWS"
      provider  = "CodeBuild"
      version   = "1"
      namespace = "BuildVariables"

      configuration = {
        "BatchEnabled" = "true"
        "ProjectName"  = "${var.project}-${var.env}"
      }

      input_artifacts = [
        "SourceArtifact"
      ]
    }
  }
}
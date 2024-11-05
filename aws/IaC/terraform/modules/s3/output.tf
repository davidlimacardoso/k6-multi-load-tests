output "name" {
  value = {
    artifact_store = aws_s3_bucket.codepipeline_artifact.id
  }
  description = "Bucket information"
}
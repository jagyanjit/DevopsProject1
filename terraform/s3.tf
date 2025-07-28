resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "project1-pipeline-artifacts-${random_id.bucket_id.hex}"
  force_destroy = true
}

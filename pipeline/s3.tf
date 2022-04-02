resource "aws_s3_bucket" "app" {
  bucket        = "${var.name_environment}-codepipeline"
  force_destroy = true
}

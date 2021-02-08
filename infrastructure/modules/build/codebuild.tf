resource "aws_codebuild_project" "build" {
  name          = "${var.project}-${var.env}-${local.region_alias}-build"
  build_timeout = "60"
  service_role  = aws_iam_role.build.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.build.bucket}/cache"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "DISTRIBUTION"
      type  = "PLAINTEXT"
      value = var.distribution.id
    }

    environment_variable {
      name  = "BUCKET"
      type  = "PLAINTEXT"
      value = var.content_bucket.id
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.build.id}/logs"
    }
  }

  source {
    type     = "S3"
    location = "${aws_s3_bucket.source.id}/source.zip"
  }

  tags = local.tags
}

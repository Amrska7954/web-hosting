resource "aws_codepipeline" "example" {
  name     = "example-pipeline"
  role_arn = aws_iam_role.example.arn

  artifact_store {
    location = var.aws_s3_bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = "Amrska7954"
        Repo       = "web-hosting"
        Branch     = "main"
        OAuthToken = "var.github_oauth_token"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = "s3-web-deployment"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "Deploy_to_S3"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      input_artifacts  = ["build_output"]
      version          = "1"
      configuration = {
        BucketName = "var.aws_s3_bucket"
        Extract    = "true"
      }
    }
  }
}


resource "aws_iam_role" "example" {
  name = "example_codepipeline_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}
# Attach a policy to the CodeBuild role

resource "aws_iam_role_policy" "example" {
  name = "example_codepipeline_policy"
  role = aws_iam_role.example.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds",
        "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource = "*",
        Effect = "Allow"
      },
    ]
  })
}

// The aws_iam_role, aws_s3_bucket, and other resources should be defined elsewhere in your Terraform configuration.

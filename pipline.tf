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
        BucketName = "your-deployment-s3-bucket-name"
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

resource "aws_iam_role_policy" "example" {
  name = "example_codepipeline_policy"
  role = aws_iam_role.example.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "s3:*",
          "iam:PassRole"
          // Include additional actions as needed by your pipeline
        ],
        Resource = "*",
        Effect = "Allow"
      },
    ]
  })
}

// The aws_iam_role, aws_s3_bucket, and other resources should be defined elsewhere in your Terraform configuration.

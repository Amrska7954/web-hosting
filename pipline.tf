# resource "aws_codepipeline" "example" {
#   name     = "example-pipeline"
#   role_arn = aws_iam_role.example.arn

#   artifact_store {
#     location = var.aws_s3_bucket
#     type     = "S3"
#   }

#   stage {
#     name = "Source"
#     action {
#       name             = "GitHub_Source"
#       category         = "Source"
#       owner            = "ThirdParty"
#       provider         = "GitHub"
#       version          = "1"
#       output_artifacts = ["source_output"]
#       configuration = {
#         Owner      = "Amrska7954"
#         Repo       = "web-hosting"
#         Branch     = "main"
#         OAuthToken = "var.github_oauth_token"
#       }
#     }
#   }

#   stage {
#     name = "Build"
#     action {
#       name             = "Build"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       input_artifacts  = ["source_output"]
#       output_artifacts = ["build_output"]
#       version          = "1"
#       configuration = {
#         ProjectName = "s3-web-deployment"
#       }
#     }
#   }

#   stage {
#     name = "Deploy"
#     action {
#       name             = "Deploy_to_S3"
#       category         = "Deploy"
#       owner            = "AWS"
#       provider         = "S3"
#       input_artifacts  = ["build_output"]
#       version          = "1"
#       configuration = {
#         BucketName = "var.aws_s3_bucket"
#         Extract    = "true"
#       }
#     }
#   }
# }


# resource "aws_iam_role" "example" {
#   name = "example_codepipeline_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "codepipeline.amazonaws.com"
#         }
#       },
#     ]
#   })
# }
# # Attach a policy to the CodeBuild role

# resource "aws_iam_role_policy" "example" {
#   name = "example_codepipeline_policy"
#   role = aws_iam_role.example.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#         "codebuild:StartBuild",
#         "codebuild:BatchGetBuilds",
#         "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "s3:PutObject",
#           "s3:GetObject",
#           "s3:GetObjectVersion"
#         ],
#         Resource = "*",
#         Effect = "Allow"
#       },
#     ]
#   })
# }

# // The aws_iam_role, aws_s3_bucket, and other resources should be defined elsewhere in your Terraform configuration.






# Define a CodeBuild project
resource "aws_codebuild_project" "example" {
  name          = "example-project"
  build_timeout = "5" # Timeout in minutes
  service_role  = aws_iam_role.codebuild.arn # IAM role ARN for CodeBuild

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/Amrska7954/web-hosting.git"
    git_clone_depth = 1
  }
}

# Define an IAM role for CodeBuild
resource "aws_iam_role" "codebuild" {
  name = "example-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

# Attach a policy to the CodeBuild role
resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion"
          // Add any other actions your build may need here
        ],
        Resource = "*",
        Effect   = "Allow"
      },
    ]
  })
}

# Define the IAM role for CodePipeline
resource "aws_iam_role" "codepipeline" {
  name = "example-codepipeline-role"

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

# Attach a policy to the CodePipeline role
resource "aws_iam_role_policy" "codepipeline" {
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
    ]
  })
}

# Define the CodePipeline
resource "aws_codepipeline" "example" {
  name     = "example-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

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
      output_artifacts = ["source_output"]
      version          = "1"
      configuration = {
        Owner      = "Amrska7954"
        Repo       = "web-hosting"
        Branch     = "main"
        OAuthToken = var.github_oauth_token
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
        ProjectName = aws_codebuild_project.example.name
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
        BucketName = "myq-test-dev12347891abc"
        Extract    = "true"
      }
    }
  }
}



variable "profile" {
  description = "The AWS profile to use"
  type        = string
  default     = "myprofile"
}

variable "github_oauth_token" {
  description = "GitHub OAuth token for CodePipeline"
  type        = string
  sensitive   = true
}

variable "aws_s3_bucket" {
  description = "S3 bucket name"
  type        = string
  default =    "myq-test-dev12347891abc"  
}

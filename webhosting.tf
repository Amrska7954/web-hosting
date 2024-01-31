# provider "aws" {
#   profile = var.profile
#   region  = "us-east-1"
# }

# # S3 bucket for site
# resource "aws_s3_bucket" "site_bucket" {
#   bucket = "myq-test-dev12347891abc"

#   website {
#     index_document = "index.html"
#     error_document = "error.html"
#   }
# }

# # S3 bucket for admin
# resource "aws_s3_bucket" "admin_bucket" {
#   bucket = "my-admin-dev12347891abc"

#   website {
#     index_document = "index.html"
#     error_document = "error.html"
#   }
# }

# # Policy for site bucket
# resource "aws_s3_bucket_policy" "site_bucket_policy" {
#   bucket = aws_s3_bucket.site_bucket.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action    = "s3:GetObject",
#         Effect    = "Allow",
#         Resource  = "arn:aws:s3:::${aws_s3_bucket.site_bucket.id}/*",
#         Principal = "*"
#       }
#     ]
#   })
# }

# # Policy for admin bucket
# resource "aws_s3_bucket_policy" "admin_bucket_policy" {
#   bucket = aws_s3_bucket.admin_bucket.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action    = "s3:GetObject",
#         Effect    = "Allow",
#         Resource  = "arn:aws:s3:::${aws_s3_bucket.admin_bucket.id}/*",
#         Principal = "*"
#       }
#     ]
#   })
# }
# # CloudFront distribution
# resource "aws_cloudfront_distribution" "s3_distribution" {
#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"

#   # Origin for site bucket
#   origin {
#     domain_name = aws_s3_bucket.site_bucket.website_endpoint
#     origin_id   = "SiteBucketOrigin"

#     custom_origin_config {
#       http_port              = 80
#       https_port             = 443
#       origin_protocol_policy = "http-only"
#       origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#     }
#   }

#   # Origin for admin bucket
#   origin {
#     domain_name = aws_s3_bucket.admin_bucket.website_endpoint
#     origin_id   = "AdminBucketOrigin"

#     custom_origin_config {
#       http_port              = 80
#       https_port             = 443
#       origin_protocol_policy = "http-only"
#       origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#     }
#   }

#   # Cache behavior for admin path
#   ordered_cache_behavior {
#     path_pattern     = "/admin*"
#     target_origin_id = "AdminBucketOrigin"
    
#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     allowed_methods        = ["GET", "HEAD", "OPTIONS"]
#     cached_methods         = ["GET", "HEAD"]
#     compress               = true
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   # Default cache behavior for site
#   default_cache_behavior {
#     target_origin_id = "SiteBucketOrigin"

#     viewer_protocol_policy = "redirect-to-https"
#     allowed_methods        = ["GET", "HEAD", "OPTIONS"]
#     cached_methods         = ["GET", "HEAD"]

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl     = 0
#     default_ttl = 86400
#     max_ttl     = 31536000
#     compress    = true
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }
# }


# //adding the data

# variable "s1" {
#   default = {
#     s1 = {
#         name = "abc"
#         gn_ipv6_address_on_creation                = false
        
#     },
#     s2 = {
#         name = "xyz"
#         gn_ipv6_address_on_creation                = false
#     }
#   }
# }


# output "v" {
#  value = [for v in var.s1: v]
# }
# output b {
#     value = [for v in var.s1: v.name]
# }

resource "aws_s3_bucket" "mybkt" {
  bucket = "my-tf-test-bucket"
  #region = "ap-south-1"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on =[aws_s3_bucket.mybkt]
  bucket = aws_s3_bucket.mybkt.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "s3-version" {
    depends_on =[aws_s3_bucket.mybkt]
    bucket = aws_s3_bucket.mybkt.id
     versioning_configuration {
    status = "Enabled"
    }  
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  depends_on =[aws_s3_bucket.mybkt]
  bucket = aws_s3_bucket.mybkt.id

  rule{
    id = "rule-1"
    filter {
      prefix = "logs/"
    }
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_object" "Object1" {
  // for_each = fileset("path/to/file")
  depends_on = [aws_s3_bucket.mybkt]
  bucket = aws_s3_bucket.mybkt
  acl = "public-read-write"
  key = "filename" // each.value for several objects  
  source = "path/to/file" //${each.value}
  //etag   = filemd5("/home/pawan/Documents/Projects/${each.value}")
}
locals {
  s3_origin_id = "s3-origin"
}
resource "aws_cloudfront_distribution" "webcdn" {
  depends_on = [aws_s3_object.Object1]
  origin {
    domain_name = aws_s3_bucket.mybkt.id
    origin_id = local.s3_origin_id
  }
  enabled = true
  default_root_object = "index.html"


  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "myprefix"
  # }
  #aliases = ["mysite.example.com", "yoursite.example.com"]
   default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
   # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
     price_class = "PriceClass_200"
   restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = false
  }
  }



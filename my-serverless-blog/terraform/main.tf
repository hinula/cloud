terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.js"
  output_path = "lambda_function.zip"
}

# ... (diğer resource’lar aynı kalacak)

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method.get_method
  ]
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "prod"
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.lambda_integration.id,
      aws_api_gateway_method.get_method.id
    ]))
  }
}

output "serverless_api_url" {
  value = "https://${aws_api_gateway_rest_api.my_api.id}.execute-api.us-east-1.amazonaws.com/prod/hello"
}

output "blog_website_endpoint" {
  value = aws_s3_bucket_website_configuration.blog_website.website_endpoint
}

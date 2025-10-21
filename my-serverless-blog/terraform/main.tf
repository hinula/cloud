# --- AWS Sağlayıcısı (Provider) Ayarları ---
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
  }
}

# AWS Bölgesi Tanımlama
provider "aws" {
  region = "us-east-1" # BÖLGE GÜNCELLENDİ: Kuzey Virginia
}

# Rastgele ID üretimi (S3 bucket ismini benzersiz yapmak için)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# ----------------------------------------------------
# 1. SERVERLESS API (ÖDEV GEREKLİLİĞİ)
# ----------------------------------------------------

# 1.1. IAM Rolü (En Az Ayrıcalık Prensibi)
resource "aws_iam_role" "lambda_exec_role" {
  name = "my_serverless_api_role_node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# CloudWatch Log İzinleri (Sadece log yazma yetkisi)
resource "aws_iam_role_policy" "lambda_log_policy" {
  name = "lambda_cloudwatch_log_policy"
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
      Effect = "Allow"
      Resource = "arn:aws:logs:*:*:*" 
    }]
  })
}

# 1.2. Lambda Fonksiyonu (index.js'i ZIP'leme)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.js" 
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "my_serverless_function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "MyFirstServerlessFunctionNode"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  timeout     = 10
  memory_size = 128
}

# 1.3. API Gateway Tanımlaması
resource "aws_api_gateway_rest_api" "my_api" {
  name = "MyServerlessAPIForProject"
}

# API Kaynağı (Path: /hello)
resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "hello"
}

# GET Metodu Tanımlama
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Entegrasyonu (Lambda Proxy)
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.hello_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_serverless_function.invoke_arn
}

# 1.4. Lambda İzni (API Gateway'in Lambda'yı çağırmasına izin verir)
resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_serverless_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*" 
}

# 1.5. API Gateway Deploy
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method.get_method
  ]
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "prod"
}

# ----------------------------------------------------
# 2. STATİK BLOG (DOKÜMANTASYON VE BLOG İÇİN)
# ----------------------------------------------------

# S3 Bucket Tanımlama
resource "aws_s3_bucket" "blog_bucket" {
  bucket = "my-serverless-project-blog-${random_id.bucket_suffix.hex}" 
}

# S3 Statik Web Sitesi Ayarları
resource "aws_s3_bucket_website_configuration" "blog_website" {
  bucket = aws_s3_bucket.blog_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

# Statik Site için Public Erişim Engeli Kaldırma
resource "aws_s3_bucket_public_access_block" "blog_bucket_public_access_block" {
  bucket = aws_s3_bucket.blog_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Politikası (Herkesin Okumasına İzin Ver)
resource "aws_s3_bucket_policy" "blog_bucket_policy" {
  bucket = aws_s3_bucket.blog_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid = "PublicReadGetObject"
      Effect = "Allow"
      Principal = "*"
      Action = "s3:GetObject"
      Resource = "${aws_s3_bucket.blog_bucket.arn}/*"
    }]
  })
}

# Blog Anasayfasını Yükleme
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.blog_bucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

# ----------------------------------------------------
# 3. ÇIKTILAR (OUTPUTS)
# ----------------------------------------------------

output "serverless_api_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}hello"
  description = "Serverless API Endpoint: Test etmek için bu URL'ye ?name=Adınız ekleyin."
}

output "blog_website_endpoint" {
  value = aws_s3_bucket_website_configuration.blog_website.website_endpoint
  description = "Statik Blog Sitenizin S3 Endpoint Adresi."
}
provider "aws" {
  region = "us-east-1" 
}

# Create a new IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_movie_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Create the Lambda function
resource "aws_lambda_function" "movie_function" {
  filename         = "lambda.py"  # path to Lambda function code
  function_name    = "movie_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "Python 3.10"  # preferred runtime
  timeout          = 10
}

# Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "movie_api" {
  name = "movie_api"
}

# Create a resource and method for the POST endpoint
resource "aws_api_gateway_resource" "movie_resource" {
  rest_api_id = aws_api_gateway_rest_api.movie_api.id
  parent_id   = aws_api_gateway_rest_api.movie_api.root_resource_id
  path_part   = "movies"
}

resource "aws_api_gateway_method" "movie_method" {
  rest_api_id   = aws_api_gateway_rest_api.movie_api.id
  resource_id   = aws_api_gateway_resource.movie_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Create a Lambda integration for the POST method
resource "aws_api_gateway_integration" "movie_integration" {
  rest_api_id             = aws_api_gateway_rest_api.movie_api.id
  resource_id             = aws_api_gateway_resource.movie_resource.id
  http_method             = aws_api_gateway_method.movie_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.movie_function.invoke_arn
}

# Create a method response to specify the response model for the API
resource "aws_api_gateway_method_response" "movie_method_response" {
  rest_api_id = aws_api_gateway_rest_api.movie_api.id
  resource_id = aws_api_gateway_resource.movie_resource.id
  http_method = aws_api_gateway_method.movie_method.http_method

  status_code = "200"
}

# Create an integration response to specify the response model for the Lambda function
resource "aws_api_gateway_integration_response" "movie_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.movie_api.id
  resource_id = aws_api_gateway_resource.movie_resource.id
  http_method = aws_api_gateway_method.movie_method.http_method

  status_code = aws_api_gateway_method_response.movie_method_response.status_code
}

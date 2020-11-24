terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
   region = "us-east-1"
}

data "archive_file" "lambda_zip" {
   type          = "zip"
   source_file   = "src/helloworld.py"
   output_path   = "lambda_function.zip"
}

resource "aws_lambda_function" "example" {
   function_name = "ServerlessExample"
   filename      = "lambda_function.zip"
   # The bucket name as created earlier with "aws s3api create-bucket"
  # s3_bucket = "terraform-serverless-example"
  # s3_key    = "v1.0.0/example.zip"

   # "main" is the filename within the zip file (main.js) and "handler"
   # is the name of the property under which the handler function was
   # exported in that file.
   handler          = "helloworld.handler"
   source_code_hash = data.archive_file.lambda_zip.output_base64sha256
   runtime          = "python3.8"
   role = aws_iam_role.lambda_exec.arn
}

 # IAM role which dictates what other AWS services the Lambda function
 # may access.
resource "aws_iam_role" "lambda_exec" {
   name = "serverless_example_lambda"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_lambda_permission" "main" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*/*"
}

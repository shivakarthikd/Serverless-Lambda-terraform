# to test: run `terraform plan`
# to deploy: run `terraform apply`

variable "aws_region" {
 default = "us-west-2"
}

provider "aws" {
 region    = var.aws_region
}

data "archive_file" "lambda_zip" {
   type          = "zip"
   source_file   = "src/helloworld.py"
   output_path   = "lambda_function.zip"
}

resource "aws_lambda_function" "test_lambda" {
 filename         = "lambda_function.zip"
 function_name    = "test_lambda"
 role             = aws_iam_role.iam_for_lambda_tf.arn
 handler          = "helloworld.handler"
 source_code_hash = data.archive_file.lambda_zip.output_base64sha256
 runtime          = "python3.8"
}

resource "aws_iam_role" "iam_for_lambda_tf" {
 name = "iam_for_lambda_tf"
 assume_role_policy = file("IAM/lamda-role.json")
}
resource "aws_lambda_permission" "main" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*/*"
}

resource "aws_api_gateway_rest_api" "main" {
  name = "lamda-api"
}

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id = aws_api_gateway_rest_api.main.root_resource_id
  path_part = "app"
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  integration_http_method = aws_api_gateway_method.main.http_method
  type = "AWS_PROXY"
  uri = aws_lambda_function.example.invoke_arn
}

resource "aws_api_gateway_integration_response" "main" {
  depends_on = [aws_api_gateway_integration.main]

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  status_code = aws_api_gateway_method_response.main.status_code
}

resource "aws_api_gateway_method" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    "aws_api_gateway_integration_response.main",
    "aws_api_gateway_method_response.main",
  ]
  rest_api_id = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_method_settings" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name = aws_api_gateway_stage.main.stage_name

  # settings not working when specifying the single method
  # refer to: https://github.com/hashicorp/terraform/issues/15119
  method_path = "*/*"

  settings {
    throttling_rate_limit = 5
    throttling_burst_limit = 10
  }
}

resource "aws_api_gateway_stage" "main" {
  stage_name = "dev-stage"
  rest_api_id = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.main.id
}

resource "aws_api_gateway_method_response" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  status_code = "200"
}

output "endpoint" {
  value = "${aws_api_gateway_stage.main.invoke_url}${aws_api_gateway_resource.main.path}"
}

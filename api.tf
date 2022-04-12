
variable "name" {
  type    = string
  default = "async-api"
}

variable "endpoint_suffix" {
  type    = string
  default = "amazonaws.com"
}

module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.name}-function"
  description   = "Wait a few seconds and log the time difference."
  handler       = "index.handler"
  memory_size   = 128
  runtime       = "nodejs14.x"
  timeout       = 10

  source_path = "${path.module}/lambda"
}

data "template_file" "json_definition" {
  template = file("${path.module}/api_definition.json")
  vars = {
    lambda_invocation_arn = module.lambda.lambda_function_invoke_arn
  }
}

data "template_file" "yaml_definition" {
  template = file("${path.module}/api_definition.yaml")
  vars = {
    lambda_invocation_arn = module.lambda.lambda_function_invoke_arn
  }
}

resource "local_file" "yaml_definition" {
  content = data.template_file.yaml_definition.rendered
  filename = "${path.module}/rendered/api_definition.yaml"
}

resource "local_file" "json_definition" {
  content = data.template_file.json_definition.rendered
  filename = "${path.module}/rendered/api_definition.json"
}

resource "aws_api_gateway_rest_api" "async_test" {
  name          = "${var.name}-api"
  body          = data.template_file.json_definition.rendered
}

resource "aws_api_gateway_deployment" "async_test" {
  rest_api_id = aws_api_gateway_rest_api.async_test.id

  triggers = {
    redeployment = sha1(data.template_file.json_definition.rendered)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "async_test" {
  deployment_id   = aws_api_gateway_deployment.async_test.id
  rest_api_id     = aws_api_gateway_rest_api.async_test.id
  stage_name      = "latest"
}

resource "aws_lambda_permission" "allow_api_gateway_invocation" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.async_test.execution_arn}/${aws_api_gateway_stage.async_test.stage_name}/*/wait/*"

  lifecycle {
    create_before_destroy = true
  }
}

output "rest_api_endpoint" {
  value = "https://${aws_api_gateway_rest_api.async_test.id}.execute-api.${var.endpoint_suffix}/${aws_api_gateway_stage.async_test.stage_name}"
}

//=================================================================================
//API Gateway
//=================================================================================

resource "aws_api_gateway_rest_api" "CloudResumeAPI" {
  name        = "CloudResumeAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "CloudResumeResource" {
  rest_api_id = aws_api_gateway_rest_api.CloudResumeAPI.id
  parent_id   = aws_api_gateway_rest_api.CloudResumeAPI.root_resource_id
  path_part   = "cloudresume"
}

resource "aws_api_gateway_method" "CloudResumeMethod" {
  rest_api_id   = aws_api_gateway_rest_api.CloudResumeAPI.id
  resource_id   = aws_api_gateway_resource.CloudResumeResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "MethodSettings" {
  rest_api_id = aws_api_gateway_rest_api.CloudResumeAPI.id
  stage_name  = aws_api_gateway_stage.CloudResumeStage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_integration" "CloudResumeIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.CloudResumeAPI.id
  resource_id             = aws_api_gateway_resource.CloudResumeResource.id
  http_method             = aws_api_gateway_method.CloudResumeMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

//=================================================================================
//Staging and Deployment
//=================================================================================

resource "aws_api_gateway_deployment" "CloudResumeDeployment" {
  rest_api_id = aws_api_gateway_rest_api.CloudResumeAPI.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.CloudResumeResource,
      aws_api_gateway_method.CloudResumeMethod,
      aws_api_gateway_integration.CloudResumeIntegration,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "CloudResumeStage" {
  deployment_id = aws_api_gateway_deployment.CloudResumeDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.CloudResumeAPI.id
  stage_name    = "prod"
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.CloudResumeLogs.arn
    format = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"
  }

  depends_on = [aws_cloudwatch_log_group.CloudResumeLogs]
}



//=================================================================================
//Lambda API Permission
//=================================================================================

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.CloudResumeAPI.id}/*/*"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

//=================================================================================
//Lambda API log group
//=================================================================================


resource "aws_api_gateway_account" "CloudResumeAccount" {
  cloudwatch_role_arn = aws_iam_role.api_logging_role.arn
}

resource "aws_cloudwatch_log_group" "CloudResumeLogs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.CloudResumeAPI.id}/prod"
  retention_in_days = 7
  # ... potentially other configuration ...
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "api_logging_policy" {
    statement {
        effect = "Allow"
        
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
        ]

        resources = ["*"]
    }
}

resource "aws_iam_role" "api_logging_role" {
  name = "APIGatewayLogging"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "default"
  role   = aws_iam_role.api_logging_role.id
  policy = data.aws_iam_policy_document.api_logging_policy.json
}

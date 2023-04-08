data "archive_file" "lambda_src" {
    type = "zip"
    source_file = "src/updateUserCount.py"
    output_path = "function.zip"
}

resource "aws_lambda_function" "lambda" {
    
    filename = "function.zip"
    function_name = "CloudResumeLambda"
    role = aws_iam_role.cloud_resume_lambda_role.arn
    handler = "updateUserCount.lambda_handler"

    source_code_hash = filebase64sha256(data.archive_file.lambda_src.output_path)

    runtime = "python3.9"

}


//=================================================================================
//Lambda IAM Resources
//=================================================================================

data "aws_iam_policy_document" "cloud_resume_policy" {
    statement {
        effect = "Allow"

        actions = [
            "dynamodb:UpdateItem"
        ]

        resources = [ var.db_arn ]
    }

    statement {
        effect = "Allow"
        
        actions = [
        "logs:CreateLogGroup"
        ]

        resources = ["arn:aws:logs:us-east-1:555531727565:*"]
    }
    statement {
        effect = "Allow"
        
        actions = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
        ]

        resources = ["arn:aws:logs:us-east-1:555531727565:log-group:/aws/lambda/CloudResumeLambda:*"]
    }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "cloud_resume_lambda_role" {
  name = "CloudResumeLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name = "CloudResumePolicy"
    policy = data.aws_iam_policy_document.cloud_resume_policy.json
  }
}

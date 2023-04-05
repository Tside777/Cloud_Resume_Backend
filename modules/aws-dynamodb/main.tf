resource "aws_dynamodb_table" "dynamo_table" {
    name = "CloudResume"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id"
    deletion_protection_enabled = true

    attribute {
        name = "id"
        type = "N"
    }
}


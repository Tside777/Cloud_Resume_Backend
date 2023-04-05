resource "aws_dynamodb_table" "dynamo_table" {
    name = "CloudResume"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id"

    attribute {
        name = "id"
        type = "N"
    }

    attribute {
        name = "userCount"
        type = "N"
    }
}

resource aws_dynamodb_table_item "keyId" {
    table_name = aws_dynamodb_table.dynamo_table
    hash_key = aws_dynamodb_table.dynamo_table.hash_key
    item = <<ITEM
    {
        "id": {"N": 1}
    }
    ITEM
}
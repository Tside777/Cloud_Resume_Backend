import boto3

def lambda_handler(event, context):

    client = boto3.resource('dynamodb')
    table = client.Table('Cloud_Resume_User_Count')
    response = table.get_item(
        Key={
            'id': 1
       }
    )

    if 'Item' in response:
        return response['Item']
    else:
       return {
           'statusCode': '404',
           'body': 'Not found'
       }
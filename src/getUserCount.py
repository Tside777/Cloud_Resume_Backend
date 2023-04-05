import boto3

def lambda_handler(event, context):

    client = boto3.resource('dynamodb')
    table = client.Table('CloudResume')
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
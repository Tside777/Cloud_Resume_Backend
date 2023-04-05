import boto3

def lambda_handler(event, context):

   client = boto3.resource('dynamodb')
   
   response = update_count(client)

   return {

       'statusCode': response['ResponseMetadata']['HTTPStatusCode'],
       'body': response['Attributes']

   }

def update_count(dynamodb):
    table = dynamodb.Table('Cloud_Resume_User_Count')

    response = table.update_item(
        Key={
            'id': 1,
        },
        UpdateExpression='ADD #userCount :q',
        ExpressionAttributeNames={
            '#userCount': 'userCount'
        },
        ExpressionAttributeValues={ 
            ':q': 1 
        },
        ReturnValues='UPDATED_NEW'
    )

    return response

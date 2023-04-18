import boto3
import json

def lambda_handler(event, context):

   client = boto3.resource('dynamodb')
   
   response = update_count(client)
   
   response['Attributes']['userCount'] = int(response['Attributes']['userCount'])
   response['ResponseMetadata']['HTTPHeaders']['Access-Control-Allow-Origin'] = '*'
   response['ResponseMetadata']['HTTPHeaders']['Access-Control-Allow-Headers'] = 'Content-Type'
   response['ResponseMetadata']['HTTPHeaders']['Access-Control-Allow-Methods'] = 'OPTIONS,GET'

   return {
        "isBase64Encoded": False,
        "statusCode": response['ResponseMetadata']['HTTPStatusCode'],
        "headers": response['ResponseMetadata']['HTTPHeaders'],
        "body": json.dumps(response['Attributes'])
    }


def update_count(dynamodb):
    table = dynamodb.Table('CloudResume')

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
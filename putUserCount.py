import boto3

def lambda_handler(event, context):

   client = boto3.resource('dynamodb')

   table = client.Table('Cloud_Resume_User_Count')

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
       }
   )

   return {

       'statusCode': response['ResponseMetadata']['HTTPStatusCode'],
       'body': 'userCount incremented'

   }
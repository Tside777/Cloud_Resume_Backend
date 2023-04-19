from moto import mock_dynamodb
import boto3
import unittest
import sys


def create_user_count_table(dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb', endpoint_url='http://localhost:8000')

    table = dynamodb.create_table(
        TableName='CloudResume',
        KeySchema=[
            {
                'AttributeName': 'id',
                'KeyType': 'HASH'
            }
        ],
        AttributeDefinitions=[
            {
                'AttributeName': 'id',
                'AttributeType': 'N'   
            },
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 1,
            'WriteCapacityUnits': 1
        }
    )

    table.meta.client.get_waiter('table_exists').wait(TableName='CloudResume')
    return table



@mock_dynamodb
class TestDatabaseFunctions(unittest.TestCase):

    def setUp(self):
        """
        Create database resource and mock table
        """
        self.dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        self.table = create_user_count_table(self.dynamodb)
        sys.path


    def test_table_exists(self):
        """
        Test if our mock table is ready
        """
        self.assertIn('CloudResume', self.table.name)
    

    def test_putUserCount(self):
        """
        Test if our method to update the count works
        """
        from updateUserCount import update_count
        result = update_count(self.dynamodb)
        self.assertEqual(200, result['ResponseMetadata']['HTTPStatusCode'])
        self.assertEqual(1, result['Attributes']['userCount'])


    def tearDown(self):
        """
        Delete database resource and mock table
        """
        self.table.delete()
        self.dynamodb=None

if __name__ == '__main__':
    unittest.main()
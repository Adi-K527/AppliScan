import requests
import os

def lambda_handler(event, context):
    response = requests.get(os.getenv('API_URL'))
    
    return {
        'statusCode': 200,
    }

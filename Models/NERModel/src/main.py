import json
import boto3
import joblib
import numpy as np
import os
from openai import OpenAI

s3_client = boto3.client('s3')

def lambda_handler(event, context):

    print("-------------------------------------    LOG 1   -------------------------------------")
    event = json.loads(event['Records'][0]['body'])
    event = json.loads(event['Message'])
    event = json.loads(event['responsePayload']['body'])

    print(event['data'])

    emails = [i[0] for i in event['data']]
    ids    = [i[1] for i in event['data']]
    uuids  = [i[2] for i in event['data']]

    client = OpenAI()

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "user", "content": f"{emails} \n\n Extract the company name from these emails, respond with the company names for each email seperated by comma."}
        ]
    )

    prediction = response.choices[0].message.content.split(', ')

    result = []
    for i in range(len(prediction)):
        result.append([prediction[i], ids[i], uuids[i], emails[i]])

    with open('/tmp/output.json', 'w') as f:
        json.dump({'data': result}, f, indent=2)

    s3_client.upload_file(Filename = '/tmp/output.json',
                          Bucket   = "appliscan-model-output-bucket", 
                          Key      = "NER/prediction.json")
    
    return {
        'statusCode': 200,
        'body': json.dumps({"Result": result})
    }
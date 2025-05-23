import json
import boto3
import joblib
import numpy as np
import os

s3_client = boto3.client('s3')

def lambda_handler(event, context):

    print("-------------------------------------    LOG 1   -------------------------------------")
    print(event)

    object_key  = event['Records'][0]['s3']['object']['key']
    bucket_name = event['Records'][0]['s3']['bucket']['name']

    s3_client.download_file(Bucket   = bucket_name, 
                            Key      = object_key, 
                            Filename = "/tmp/text.txt")
    
    s3_client.download_file(Bucket   = "appliscan-bucket-325", 
                            Key      = "Job_related_Model.joblib", 
                            Filename = "/tmp/model.joblib")
    
    model = joblib.load('/tmp/model.joblib')      

    print("-------------------------------------    LOG 2   -------------------------------------")

    with open("/tmp/text.txt", "r") as file:
        text = json.loads(file.read())
        print(text)

    prediction = model.predict(text['emails'])

    print("-------------------------------------    LOG 3   -------------------------------------")
    print(prediction)

    res_data = [[text['emails'][i], text['ids'][i], text['uuids'][i]] for i in range(len(text['emails'])) if prediction[i] == 'Yes']
    
    return {
        'statusCode': 200,
        'body': json.dumps({"data": list(res_data)})
    }
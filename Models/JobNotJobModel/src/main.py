import json
import boto3
import joblib
import numpy as np
import os

s3_client = boto3.client('s3')

def lambda_handler(event, context):

    print("-------------------------------------    LOG 1   -------------------------------------")
    print(event["body"])
    
    s3_client.download_file(Bucket   = "appliscan-bucket-325", 
                            Key      = "Job_related_Model.joblib", 
                            Filename = "/tmp/model.joblib")
    model = joblib.load('/tmp/model.joblib')      

    print("-------------------------------------    LOG 2   -------------------------------------")
    print(model)

    prediction = model.predict([event["body"]])

    print("-------------------------------------    LOG 3   -------------------------------------")
    print(prediction)
    
    return {
        'statusCode': 200,
        'body': json.dumps({"prediction": list(prediction)})
    }
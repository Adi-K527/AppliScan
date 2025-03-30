import json
import boto3
import joblib
import numpy as np
import os


def lambda_handler(event, context):

    print("-------------------------------------    LOG 1   -------------------------------------")
    print(event["body"])
    
    bucket = boto3.resource('s3').Bucket("appliscan-bucket-325")
    bucket.download_file('Job_related_Model.joblib', '/tmp/model.joblib')
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
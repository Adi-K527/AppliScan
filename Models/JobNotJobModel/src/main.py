import json
import boto3
import joblib
import numpy as np
import os


def np_encoder(object):
    if isinstance(object, np.generic):
        return object.item()


def lambda_handler(event, context):

    print("-------------------------------------    LOG 1   -------------------------------------")
    print(event["body"])
    
    bucket = boto3.resource('s3', 
                            aws_access_key_id=os.getenv('MY_AWS_ACCESS_THING'), 
                            aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS')).Bucket(os.getenv('AWS_BUCKET'))
    
    bucket.download_file('Job_related_Model.joblib', '/tmp/model.joblib')
    model = joblib.load('/tmp/model.joblib')      

    print("-------------------------------------    LOG 2   -------------------------------------")
    print(model)

    prediction = model.predict([event["body"]])

    print("-------------------------------------    LOG 3   -------------------------------------")
    print(prediction)
    
    return {
        'statusCode': 200,
        'body': json.dumps({"prediction": prediction}, default=np_encoder)
    }
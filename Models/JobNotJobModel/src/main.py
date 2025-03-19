import json
import boto3
import joblib
import numpy as np
import os


def np_encoder(object):
    if isinstance(object, np.generic):
        return object.item()


def lambda_handler(event, context):
    
    bucket = boto3.resource('s3', 
                            aws_access_key_id=os.getenv('MY_AWS_ACCESS_THING'), 
                            aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS')).Bucket(os.getenv('AWS_BUCKET'))
    
    bucket.download_file('Job_related_Model.joblib', '/tmp/model.joblib')
    model = joblib.load('/tmp/model.joblib')        
    prediction = model.predict([event["body"]])
    
    return {
        'statusCode': 200,
        'body': json.dumps({"prediction": prediction[0]}, default=np_encoder)
    }
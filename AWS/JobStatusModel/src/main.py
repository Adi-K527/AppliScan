import json
import boto3
import joblib
import spacy
import re
import numpy as np
import os


def np_encoder(object):
    if isinstance(object, np.generic):
        return object.item()


def lambda_handler(event, context):
    
    bucket = boto3.resource('s3', 
                            aws_access_key_id=os.getenv('AWS_ACCESS_KEY'), 
                            aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS')).Bucket(os.getenv('AWS_BUCKET'))
    
    bucket.download_file('Models/JobStatusModel/Job_Status_Preprocessing_Pipeline.joblib', 
                                      '/tmp/preprocessing_pipeline.joblib')
    
    bucket.download_file('Models/JobStatusModel/Job_Status_Model.joblib', 
                                      '/tmp/model.joblib')

    model = joblib.load('/tmp/model.joblib')
    preprocessing_pipeline = joblib.load('/tmp/preprocessing_pipeline.joblib') 
    
    
    data_preprocessed = preprocessing_pipeline.transform([event["body"]])
    
    prediction = model.predict(data_preprocessed)
    
    return {
        'statusCode': 200,
        'body': json.dumps({"prediction": prediction[0]}, default=np_encoder)
    }
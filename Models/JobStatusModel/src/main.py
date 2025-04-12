import json
import boto3
import joblib
import numpy as np


def np_encoder(object):
    if isinstance(object, np.generic):
        return object.item()

s3_client = boto3.client('s3')

def lambda_handler(event, context):

    print("-------------------------------------    LOG 1   -------------------------------------")
    event = json.loads(event['Records'][0]['body'])
    print(event['Message'])
    event = event['Message']['responsePayload']['body']
    print(event)

    emails = [i[0] for i in event['data']]

    s3_client.download_file(Bucket   = "appliscan-bucket-325", 
                            Key      = "Job_Status_Preprocessing_Pipeline.joblib", 
                            Filename = "/tmp/preprocessing_pipeline.joblib")
    
    s3_client.download_file(Bucket   = "appliscan-bucket-325", 
                            Key      = "Job_Status_Model.joblib", 
                            Filename = "/tmp/model.joblib")

    model = joblib.load('/tmp/model.joblib')
    preprocessing_pipeline = joblib.load('/tmp/preprocessing_pipeline.joblib') 

    print("-------------------------------------    LOG 2   -------------------------------------")
    print(model, preprocessing_pipeline)
    
    data_preprocessed = preprocessing_pipeline.transform(emails)
    prediction = model.predict(data_preprocessed)

    print("-------------------------------------    LOG 3   -------------------------------------")
    print(prediction)
    
    return {
        'statusCode': 200,
        'body': json.dumps({"prediction": prediction[0]}, default=np_encoder)
    }
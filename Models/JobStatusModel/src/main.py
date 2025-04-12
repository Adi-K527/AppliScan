import json
import boto3
import joblib
import numpy as np

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
    prediction = [i.item() for i in prediction]

    result = []
    for i in range(len(prediction)):
        result.append([prediction[i], ids[i], uuids[i], emails[i]])

    with open('/tmp/output.json', 'w') as f:
        json.dump({'data': result}, f, indent=2)

    s3_client.upload_file(Filename = '/tmp/output.json',
                          Bucket   = "appliscan-model-output-bucket", 
                          Key      = "Job_Status/prediction.json")
    
    return {
        'statusCode': 200,
        'body': json.dumps({"Result": result})
    }
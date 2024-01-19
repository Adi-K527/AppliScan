import json
import boto3
import joblib
import spacy
import re

def tokenizer(doc):
    nlp = spacy.blank('en')

    tokens = [t.lower_ for t in nlp(doc) if
                        not t.is_stop and
                        not t.is_punct and
                        t.is_alpha]

    #removes url type strings
    reg = re.compile(r'http\S+|www\.\S+|ftp://\S+')
    tokens = [t for t in tokens if not reg.search(t)]

    return ' '.join(tokens)

    #access key: AKIATAEY5FC5KMTYBH4M
    #secret access key: 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
    
bucket = boto3.resource('s3', 
                        aws_access_key_id='AKIATAEY5FC5KMTYBH4M', 
                        aws_secret_access_key='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').Bucket('appliscan-bucket')

bucket.download_file('Models/Job_Status_Preprocessing_Pipeline.joblib', 
                                    '/tmp/preprocessing_pipeline.joblib')

bucket.download_file('Models/Job_Status_Model.joblib', 
                                    '/tmp/model.joblib')

model = joblib.load('/tmp/model.joblib')
preprocessing_pipeline = joblib.load('/tmp/preprocessing_pipeline.joblib')    


data_preprocessed = preprocessing_pipeline.transform([tokenizer("unfortunately")])

prediction = model.predict([data_preprocessed])
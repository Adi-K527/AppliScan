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
                            aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'), 
                            aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY')).Bucket(os.getenv('AWS_BUCKET'))
    
    bucket.download_file('Models/Job_Status_Preprocessing_Pipeline.joblib', 
                                      '/tmp/preprocessing_pipeline.joblib')
    
    bucket.download_file('Models/Job_Status_Model.joblib', 
                                      '/tmp/model.joblib')

    try:
        model = joblib.load('/tmp/model.joblib')
        preprocessing_pipeline = joblib.load('/tmp/preprocessing_pipeline.joblib')
    except Exception as e:
        return {
            'status': 500,
            'body': str(e)
        }      
    
    
    data_preprocessed = preprocessing_pipeline.transform([event["body"]])
    
    prediction = model.predict(data_preprocessed)
    
    return {
        'statusCode': 200,
        'body': json.dumps({"prediction": prediction[0]}, default=np_encoder)
    }

# import json
# import boto3
# import joblib
# import spacy
# import re
# from sklearn.decomposition import PCA
# from sklearn.feature_extraction.text import TfidfVectorizer
# from io import StringIO
# import pandas as pd



# def tokenizer(doc):
#   nlp = spacy.blank('en')
#   tokens = [t.lower_ for t in nlp(doc) if
#                       not t.is_stop and
#                       not t.is_punct and
#                       t.is_alpha]

#   #removes url type strings
#   reg = re.compile(r'http\S+|www\.\S+|ftp://\S+')
#   tokens = [t for t in tokens if not reg.search(t)]

#   return tokens


# def lambda_handler(event, context):
    
#     s3 = boto3.client('s3', aws_access_key_id='AKIATAEY5FC5KMTYBH4M', 
#                             aws_secret_access_key='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', 
#                             region_name='us-east-1')
    
#     print("hit")

#     obj = s3.get_object(Bucket='appliscan-bucket', Key='dataset/Email-Dataset')

#     corpus = pd.read_csv(StringIO(obj['Body'].read().decode('utf-8')))

#     print("hit")

#     tfidf = TfidfVectorizer(tokenizer=tokenizer)
#     tfidf.fit(corpus['Email'])

#     # print("hit")    

#     # pca = PCA(n_components=200)
#     # pca.fit(tfidf_corpus)

#     # print("hit")

#     return {
#         'statusCode': 200,
#         'body': json.dumps(tfidf.transform([event]).toarray())
#     }

    

#     try:
#         data = event['body']
#     except Exception as e:
#         return {
#             'status': 500,
#             'body': str(e)
#         }  
    
#     return {
#         'statusCode': 200,
#         'body': pca.transform(tfidf.transform(data))
#     }

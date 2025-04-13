import boto3
import pandas as pd
import requests


def process_df(df):
  predictions = []
  ids         = []
  uuids       = []
  emails      = []

  for i in range(df.shape[0]):
    for j in df.iloc[i]:
      predictions.append(j[0])
      ids.append(j[1])
      uuids.append(j[2])
      emails.append(j[3])

  return pd.DataFrame({
      'predictions': predictions,
      'ids': ids,
      'uuids': uuids,
      'emails': emails
  })


s3_client = boto3.client('s3')

s3_client.download_file(Bucket   = "appliscan-model-output-bucket",
                        Key      = "Job_Status/prediction.json", 
                        Filename = "/tmp/job_status_prediction.json")

s3_client.download_file(Bucket   = "appliscan-model-output-bucket",
                        Key      = "NER/prediction.json", 
                        Filename = "/tmp/ner_prediction.json")

status_df = pd.read_json("/tmp/job_status_prediction.json")
ner_df    = pd.read_json("/tmp/ner_prediction.json")

status_df_processed = process_df(status_df)
ner_df_processed    = process_df(ner_df)

df_merged = pd.merge(status_df_processed, ner_df_processed, 
                                   on='uuids', how='inner')

df_merged.drop(columns=['uuids'], inplace=True)

response = requests.post(url='https://appliscan-cloudrun-backend-8264-1081683483960.us-central1.run.app/data',
                         headers={'Content-Type': 'application/json'},
                         json=df_merged.values.tolist())


s3_client.delete_object(Bucket   = "appliscan-model-output-bucket",
                        Key      = "Job_Status/prediction.json")

s3_client.delete_object(Bucket   = "appliscan-model-output-bucket",
                        Key      = "NER/prediction.json")

print(response.status_code)
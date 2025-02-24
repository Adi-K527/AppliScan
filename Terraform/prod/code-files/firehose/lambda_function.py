import json
import base64

def lambda_handler(event, context):
    
    records_transformed = []

    for record in event['records']:
       record_id = record['recordId']
       data_raw  = base64.b64decode(record['data']).decode('utf-8')

       data_json = json.loads(data_raw)

       print("Data ID: ", data_json['id'])

       transformed_data = base64.b64encode(json.dumps(data_json).encode("utf-8")).decode("utf-8")

       records_transformed.append({
           'recordId': record_id,
           'result': 'Ok',
           'data': transformed_data
       })
    
    print(records_transformed)
    return {
        'records': records_transformed
    }

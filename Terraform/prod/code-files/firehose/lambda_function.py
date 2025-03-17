import json
import uuid
import base64

def lambda_handler(event, context):
    record_id = event['records'][0]['recordId']

    emails = []
    uuids  = []

    for record in event['records']:
       uuids.append(str(uuid.uuid4()))
       emails.append(record['data'])

    transformed_data = base64.b64encode(json.dumps({
        'emails': emails,
        'uuids':  uuids
    }).encode("utf-8")).decode("utf-8")
    
    print(transformed_data)
    return {
        'recordId': record_id,
        'result':   'Ok',
        'records':  transformed_data
    }

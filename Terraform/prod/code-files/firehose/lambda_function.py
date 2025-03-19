import json
import uuid
import base64

def lambda_handler(event, context):
    record_id = event['records'][0]['recordId']

    print(event['records'])

    compiled_records = []

    emails = []
    ids    = [] 
    uuids  = []

    for record in event['records']:
       record_body = json.loads(base64.b64decode(record['data']).decode("utf-8"))

       cur_id = record_body[0]['id']
       cur_emails = [i['body'] for i in record_body]

       compiled_records.append({
           'id':       cur_id,
           'emails':   cur_emails
       })

    for record in compiled_records:
        emails.extend(record['emails'])
        ids.extend([record['id'] for i in record['emails']])
        uuids.extend([str(uuid.uuid4()) for i in record['emails']])

    transformed_data = base64.b64encode(json.dumps({
        'emails': emails,
        'ids':    ids,
        'uuids':  uuids
    }).encode("utf-8")).decode("utf-8")
    
    print(transformed_data)
    return {
        "records": [
            {
                'recordId': record_id,
                'result':   'Ok',
                'data':  transformed_data
            }
        ]
    }

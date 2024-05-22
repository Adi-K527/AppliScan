print("actually started everything")
import json
print("import json")
import boto3
print("import boto3")
import numpy as np
print("import numpy as np")
import os
print("import os")
import torch
print("import torch")
import string
print("import string")
import builtins
print("import builtins")
from collections import defaultdict
print("from collections import defaultdict")
from transformers import BertForTokenClassification, BertTokenizer, BertConfig
print("from transformers import BertForTokenClassification, BertTokenizer, BertConfig")


def pad_sequences(arr, maxlen):
    for i in range(maxlen - len(arr)):
      arr.append(0)
    return [arr]


def preprocess_input(s, tokenizer, MAX_LEN):
  tokens = tokenizer.tokenize(s)
  tokens_converted = tokenizer.convert_tokens_to_ids(tokens)

  attention_mask = pad_sequences([1.0 for i in range(len(tokens))], maxlen=MAX_LEN)
  tokens_padded = pad_sequences(tokens_converted, maxlen=MAX_LEN)

  attention_mask = torch.tensor(attention_mask, dtype=float)
  tokens_padded = torch.tensor(tokens_padded, dtype=float)

  return torch.utils.data.TensorDataset(tokens_padded, attention_mask), tokens



def predict(model, input_str, device):
  s, initial_tokens = preprocess_input(input_str)
  model.eval()
  input_ids = s[0][0].unsqueeze(0).long().to(device)
  attention_mask = s[0][1].unsqueeze(0).long().to(device)
  pred = []

  with torch.no_grad():
    output = model(input_ids=input_ids, attention_mask=attention_mask)
    attention_mask = attention_mask.bool()
    pred = torch.argmax(output[0][0], axis=1)[attention_mask[0]]

  return (initial_tokens, pred.cpu().numpy(), output[0][0][attention_mask[0]])



def extract_name(arr, probs):
  visited = set()
  company_dict = defaultdict(int)
  for i in range(len(arr)):
    if i in visited:
      continue
    if arr[i][1] == 3:
      l, r = i, i
      while (l > 0 and arr[l][0][0] == '#') or (l > 0 and arr[l - 1][0][-1] == '#'):
        l -= 1
      while (r < len(arr) and arr[r][0][-1] == '#') or (r < len(arr) - 1 and arr[r + 1][0][0] == '#'):
        r += 1

      thing = ""
      full_str = arr[l:r+1]
      for j in full_str:
        for k in j[0]:
          if k != '#':
            thing += k

      company_dict[thing] += 1
      for x in range(l, r+1):
        visited.add(x)

  stop_words = set(['','i','me','my','myself','we','our','ours','ourselves','you',"you're","you've","you'll","you'd",'your','yours','yourself',
                    'yourselves','he','him','his','himself','she',"she's",'her','hers','herself','it',"it's",'its','itself','they','them','their',
                    'theirs','themselves','what','which','who','whom','this','that',"that'll",'these','those','am','is','are','was','were','be',
                    'been','being','have','has','had','having','do','does','did','doing','a','an','the','and','but','if','or','because','as',
                    'until','while','of','at','by','for','with','about','against','between','into','through','during','before','after','above',
                    'below','to','from','up','down','in','out','on','off','over','under','again','further','then','once','here','there','when',
                    'where','why','how','all','any','both','each','few','more','most','other','some','such','no','nor','not','only','own','same',
                    'so','than','too','very','s','t','can','will','just','don',"don't",'should',"should've",'now','d','ll','m','o','re','ve','y',
                    'ain','aren',"aren't",'couldn',"couldn't",'didn',"didn't",'doesn',"doesn't",'hadn',"hadn't",'hasn',"hasn't",'haven',"haven't",
                    'isn',"isn't",'ma','mightn',"mightn't",'mustn',"mustn't",'needn',"needn't",'shan',"shan't",'shouldn',"shouldn't",'wasn',
                    "wasn't",'weren',"weren't",'won',"won't",'wouldn',"wouldn't",''])

  bad = []
  for i in company_dict:
    if i.lower() in stop_words or i.lower() in string.punctuation:
      bad.append(i)
  for i in bad:
    company_dict.pop(i)

  arr = sorted([[i, company_dict[i]] for i in company_dict], reverse=True)
  if not arr:
    return ""
  return arr[0][0]



def lambda_handler(event, context):
    print("------------------STARTED EXECUTION----------------------", "\n\n")

    bucket = boto3.resource('s3', 
                            aws_access_key_id=os.getenv('MY_AWS_ACCESS_THING'), 
                            aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS')).Bucket(os.getenv('AWS_BUCKET'))
    

    bert_model_config = bucket.download_file('Models/bert_model/config.json', '/tmp/config.json')
    bert_movel_tensors = bucket.download_file('Models/bert_model/model.safetensors', '/tmp/model.safetensors')

    print("------------------GOT MODEL STUFF----------------------","\n\n")

    config = BertConfig.from_pretrained(bert_model_config)
    model = BertForTokenClassification(config)
    model.load_state_dict(torch.load(bert_movel_tensors))
    tokenizer = BertTokenizer.from_pretrained('bert-base-cased', do_lower_case=False)

    print("------------------LOADED ALL MODELS----------------------","\n\n")

    t, p, probs = predict(event['body'], tokenizer, 125)
    arr = list(builtins.zip(t, p))
    company_name = extract_name(arr, probs)

    print("------------------EXTRACTED COMPANY NAME----------------------","\n\n")

    return {
        'statusCode': 200,
        'body': json.dumps({"Extracted Name ": company_name})
    }
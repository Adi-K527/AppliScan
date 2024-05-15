print("actually started everything")
import json
print("import json")
import boto3
print("import boto3")
import numpy as np
print("import numpy as np")
import os
print("import os")
#import torch
import string
print("import string")
import nltk
print("import nltk")
import builtins
print("import builtins")
from nltk.corpus import stopwords
print("from nltk.corpus import stopwords")
from collections import defaultdict
print("from collections import defaultdict")
from keras.preprocessing.sequence import pad_sequences
print("from keras.preprocessing.sequence import pad_sequences")
from transformers import BertForTokenClassification, BertTokenizer, BertConfig
print("from transformers import BertForTokenClassification, BertTokenizer, BertConfig")
from torch.utils.data import TensorDataset
print("from torch.utils.data import TensorDataset")



# def preprocess_input(s, tokenizer, MAX_LEN):
#   tokens = tokenizer.tokenize(s)
#   tokens_converted = tokenizer.convert_tokens_to_ids(tokens)

#   attention_mask = pad_sequences([[1.0 for i in range(len(tokens))]], maxlen=MAX_LEN, padding='post')
#   tokens_padded = pad_sequences([tokens_converted], maxlen=MAX_LEN, padding='post')

#   attention_mask = torch.tensor(attention_mask, dtype=float)
#   tokens_padded = torch.tensor(tokens_padded, dtype=float)

#   return TensorDataset(tokens_padded, attention_mask), tokens



# def predict(model, input_str, device):
#   s, initial_tokens = preprocess_input(input_str)
#   model.eval()
#   input_ids = s[0][0].unsqueeze(0).long().to(device)
#   attention_mask = s[0][1].unsqueeze(0).long().to(device)
#   pred = []

#   with torch.no_grad():
#     output = model(input_ids=input_ids, attention_mask=attention_mask)
#     attention_mask = attention_mask.bool()
#     pred = torch.argmax(output[0][0], axis=1)[attention_mask[0]]

#   return (initial_tokens, pred.cpu().numpy(), output[0][0][attention_mask[0]])



# def extract_name(arr, probs):
#   visited = set()
#   company_dict = defaultdict(int)
#   for i in range(len(arr)):
#     if i in visited:
#       continue
#     if arr[i][1] == 3:
#       l, r = i, i
#       while (l > 0 and arr[l][0][0] == '#') or (l > 0 and arr[l - 1][0][-1] == '#'):
#         l -= 1
#       while (r < len(arr) and arr[r][0][-1] == '#') or (r < len(arr) - 1 and arr[r + 1][0][0] == '#'):
#         r += 1

#       thing = ""
#       full_str = arr[l:r+1]
#       for j in full_str:
#         for k in j[0]:
#           if k != '#':
#             thing += k

#       company_dict[thing] += 1
#       for x in range(l, r+1):
#         visited.add(x)

#   stop_words = set(stopwords.words("english"))

#   bad = []
#   for i in company_dict:
#     if i.lower() in stop_words or i.lower() in string.punctuation:
#       bad.append(i)
#   for i in bad:
#     company_dict.pop(i)

#   arr = sorted([[i, company_dict[i]] for i in company_dict], reverse=True)
#   if not arr:
#     return ""
#   return arr[0][0]



def lambda_handler(event, context):
    print("------------------STARTED EXECUTION----------------------", "\n\n")

    # nltk.download('stopwords')

    # print("------------------DOWNLOADED STOPWORDS----------------------", "\n\n")

    # bucket = boto3.resource('s3', 
    #                         aws_access_key_id=os.getenv('MY_AWS_ACCESS_THING'), 
    #                         aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS')).Bucket(os.getenv('AWS_BUCKET'))
    

    # bert_model_config = bucket.get_object('Models/bert_model/config.json', '/tmp/bert_model/config.json')
    # bert_movel_tensors = bucket.get_object('Models/bert_model/model.safetensors', '/tmp/bert_model/model.safetensors')

    # print("------------------GOT MODEL STUFF----------------------","\n\n")

    # config = BertConfig.from_pretrained(bert_model_config)
    # model = BertForTokenClassification(config)
    # model.load_state_dict(torch.load(bert_movel_tensors))
    # tokenizer = BertTokenizer.from_pretrained('bert-base-cased', do_lower_case=False)

    # print("------------------LOADED ALL MODELS----------------------","\n\n")

    # t, p, probs = predict(event['body'], tokenizer, 125)
    # arr = list(builtins.zip(t, p))
    # company_name = extract_name(arr, probs)

    # print("------------------EXTRACTED COMPANY NAME----------------------","\n\n")

    return {
        'statusCode': 200,
        'body': json.dumps({"Extracted Name ": "company_name"})
    }
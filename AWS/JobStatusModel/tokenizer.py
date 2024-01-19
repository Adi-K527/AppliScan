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

  return tokens
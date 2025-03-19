FROM public.ecr.aws/lambda/python:3.8-slim

WORKDIR ${LAMBDA_TASK_ROOT}

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt  

COPY src/ .

CMD [ "main.lambda_handler" ]

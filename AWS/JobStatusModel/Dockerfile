FROM public.ecr.aws/lambda/python:3.8

WORKDIR ${LAMBDA_TASK_ROOT}

ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    AWS_BUCKET=${AWS_BUCKET}

COPY requirements.txt .

RUN yum -y install libgomp

RUN pip install -r requirements.txt 

COPY src/ .

CMD [ "main.lambda_handler" ]

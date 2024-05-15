FROM public.ecr.aws/lambda/python:3.8

WORKDIR ${LAMBDA_TASK_ROOT}

COPY requirements.txt .

RUN yum -y install libgomp

RUN pip install -r requirements.txt --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cpu

COPY src/ .

CMD [ "main.lambda_handler" ]

FROM public.ecr.aws/lambda/python:3.8

WORKDIR ${LAMBDA_TASK_ROOT}

COPY requirements.txt .

RUN yum -y install libgomp
RUN apt-get update && \
    apt-get install -y build-essential g++ && \
    rm -rf /var/lib/apt/lists/*


RUN pip install -r requirements.txt 

COPY src/ .

CMD [ "main.lambda_handler" ]

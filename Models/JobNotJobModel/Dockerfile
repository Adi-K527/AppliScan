FROM public.ecr.aws/lambda/python:3.8

WORKDIR ${LAMBDA_TASK_ROOT}

COPY requirements.txt .

RUN yum -y groupinstall "Development Tools" && \
    yum -y install gcc-c++ libgomp && \
    yum clean all

RUN pip install --no-cache-dir -r requirements.txt 

COPY src/ .

CMD [ "main.lambda_handler" ]

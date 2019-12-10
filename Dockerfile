FROM artembo/python-texlive:latest

ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

RUN mkdir /doc
WORKDIR /doc

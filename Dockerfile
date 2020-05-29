FROM artembo/python-texlive:latest

ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

RUN apt update && apt install -y luarocks && \
    luarocks install penlight

ADD https://api.github.com/repos/tarantool/LDoc/git/refs/heads/tarantool version.json
RUN git clone https://github.com/tarantool/LDoc.git /usr/local/ldoc

RUN curl -L https://tarantool.io/installer.sh | bash

RUN mkdir /doc
WORKDIR /doc

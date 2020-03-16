FROM artembo/python-texlive:latest

ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

RUN apt update && apt install -y luarocks pandoc && \
    luarocks install penlight

ADD https://api.github.com/repos/artembo/LDoc/git/refs/heads/master version.json
RUN git clone https://github.com/artembo/LDoc.git /usr/local/ldoc

RUN mkdir /doc
WORKDIR /doc

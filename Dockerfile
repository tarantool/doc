FROM packpack/packpack:ubuntu-xenial

COPY requirements.txt /requirements.txt

RUN apt-get update && apt-get -y install pkg-config lua5.1-dev python-pip python-setuptools python-dev texlive texlive-latex-extra xzdec texlive-lang-cyrillic imagemagick librsvg2-bin
  
RUN pip install -r /requirements.txt --upgrade

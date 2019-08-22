FROM artembo/python-texlive:latest

RUN pip install Sphinx==1.8.5 sphinx-intl lupa docutils==0.14

RUN mkdir /doc
WORKDIR /doc

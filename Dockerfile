FROM python:2.7


RUN apt-get update && apt-get -y install \
 texlive \
  texlive-latex-base-doc- \
 texlive-latex-extra \
  texlive-latex-extra-doc- \
  texlive-latex-recommended-doc- \
  texlive-fonts-recommended-doc- \
  texlive-pictures-doc- \
  texlive-pstricks-doc- \
 xzdec \
 texlive-fonts-extra \
 texlive-lang-cyrillic \
 texlive-extra-utils \
 imagemagick \
 inkscape \
 node-less \
 cmake

RUN pip install Sphinx==1.8.5 sphinx-intl lupa docutils==0.14

RUN mkdir /doc
WORKDIR /doc

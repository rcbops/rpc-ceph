FROM python:alpine3.6

RUN apk -U --no-cache add enchant make aspell-en wget tar git && \
    wget -qO- https://github.com/jgm/pandoc/releases/download/2.0.2/pandoc-2.0.2-linux.tar.gz | tar xvz -C /usr/local
RUN pip install doc8 pyenchant sphinxcontrib-spelling sphinxcontrib-versioning sphinx==1.6.5 sphinx_rtd_theme recommonmark markdown sphinxcontrib-pandoc-markdown
RUN mkdir /docs
VOLUME ["/data"]
WORKDIR /data/docs/
ENV PATH="/usr/local/pandoc-2.0.2/bin:${PATH}"

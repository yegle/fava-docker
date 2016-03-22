FROM python:3.5.1-alpine

ENV BEANCOUNT_INPUT_FILE ""
ENV FAVA_OPTIONS "-H 0.0.0.0"

RUN apk add --update \
        libxml2 \
        libxslt \
        libxml2-dev \
        libxslt-dev \
        gcc \
        musl-dev \
        python3-dev \
        && python3 -mpip install beancount-fava \
        && python3 -mpip uninstall --yes pip \
        && rm -rf /root/.cache \
        && apk del libxml2-dev \
        libxslt-dev \
        gcc \
        musl-dev \
        python3-dev \
        && rm -rf /var/cache/apk/*

# Default fava port number
EXPOSE 5000

CMD fava $FAVA_OPTIONS $BEANCOUNT_INPUT_FILE

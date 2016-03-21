FROM python:3.5.1-alpine

ENV BEANCOUNT_INPUT_FILE ""
ENV FAVA_OPTIONS "-p 5555 -H 0.0.0.0"

RUN apk add --update \
	libxml2 \
	libxslt \
	libxml2-dev \
	libxslt-dev \
	gcc \
	musl-dev \
	python3-dev
RUN python3 -mpip install beancount-fava
RUN python3 -mpip uninstall --yes pip
RUN rm -rf /root/.cache

RUN apk del libxml2-dev \
	libxslt-dev \
	gcc \
	musl-dev \
	python3-dev
RUN rm -rf /var/cache/apk/*

CMD fava $FAVA_OPTIONS $BEANCOUNT_INPUT_FILE

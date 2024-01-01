ARG BEANCOUNT_VERSION=2.3.6
ARG FAVA_VERSION=v1.26.2

ARG NODE_BUILD_IMAGE=16-bullseye
FROM node:${NODE_BUILD_IMAGE} as node_build_env
ARG FAVA_VERSION

WORKDIR /tmp/build
RUN git clone https://github.com/beancount/fava

RUN apt-get update
RUN apt-get install -y python3-babel

WORKDIR /tmp/build/fava
RUN git checkout ${FAVA_VERSION}
RUN make
RUN rm -rf .*cache && \
    rm -rf .eggs && \
    rm -rf .tox && \
    rm -rf build && \
    rm -rf dist && \
    rm -rf frontend/node_modules && \
    find . -type f -name '*.py[c0]' -delete && \
    find . -type d -name "__pycache__" -delete

FROM debian:bullseye as build_env
ARG BEANCOUNT_VERSION

RUN apt-get update
RUN apt-get install -y build-essential libxml2-dev libxslt-dev curl \
        python3 libpython3-dev python3-pip git python3-venv


ENV PATH "/app/bin:$PATH"
RUN python3 -mvenv /app
COPY --from=node_build_env /tmp/build/fava /tmp/build/fava

WORKDIR /tmp/build
RUN git clone https://github.com/beancount/beancount

WORKDIR /tmp/build/beancount
RUN git checkout ${BEANCOUNT_VERSION}

RUN CFLAGS=-s pip3 install -U /tmp/build/beancount
RUN pip3 install -U /tmp/build/fava
ADD requirements.txt .
RUN pip3 install -U -r requirements.txt

RUN pip3 uninstall -y pip

RUN find /app -name __pycache__ -exec rm -rf -v {} +

#Distroless is too limited for my use.
#FROM gcr.io/distroless/python3-debian11
# I use Python
FROM python:3.9.18-bullseye
COPY --from=build_env /app /app
RUN apt-get update
RUN apt-get install -y git nano poppler-utils wget

# Default fava port number
EXPOSE 5000

ENV BEANCOUNT_FILE ""

ENV FAVA_HOST "0.0.0.0"
ENV PATH "/app/bin:$PATH"
ENV PYTHONPATH "/myData/myTools:$PYTHONPATH"

ENTRYPOINT ["fava"]

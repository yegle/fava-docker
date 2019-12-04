ARG BEANCOUNT_VERSION=2.2.3
ARG NODE_BUILD_IMAGE=10.17.0-buster

FROM node:${NODE_BUILD_IMAGE} as node_build_env
ARG SOURCE_BRANCH
ENV FAVA_VERSION=${SOURCE_BRANCH:-v1.12}

WORKDIR /tmp/build
RUN git clone https://github.com/beancount/fava
WORKDIR /tmp/build/fava
RUN git checkout ${FAVA_VERSION}
RUN make
RUN make mostlyclean

FROM debian:buster as build_env
ARG BEANCOUNT_VERSION

ENV BEANCOUNT_URL https://bitbucket.org/blais/beancount/get/${BEANCOUNT_VERSION}.tar.gz

RUN apt-get update
RUN apt-get install -y build-essential libxml2-dev libxslt-dev curl \
        python3 libpython3-dev python3-pip git python3-venv

WORKDIR /tmp/build

ENV PATH "/app/bin:$PATH"

RUN python3 -mvenv /app

RUN pip3 install -U pip setuptools

RUN curl -J -L ${BEANCOUNT_URL} -o beancount-${BEANCOUNT_VERSION}.tar.gz
RUN tar xvf beancount-${BEANCOUNT_VERSION}.tar.gz
RUN CFLAGS=-s pip3 install -U ./beancount-*

COPY --from=node_build_env /tmp/build/fava /tmp/build/fava
RUN pip3 install -U ./fava

RUN find /app -name __pycache__ -exec rm -rf -v {} +

FROM gcr.io/distroless/python3-debian10
COPY --from=build_env /app /app

# Default fava port number
EXPOSE 5000

ENV BEANCOUNT_FILE ""

# Required by Click library.
# See https://click.palletsprojects.com/en/7.x/python3/
ENV LC_ALL "C.UTF-8"
ENV LANG "C.UTF-8"
ENV FAVA_HOST "0.0.0.0"
ENV PATH "/app/bin:$PATH"

ENTRYPOINT ["fava"]

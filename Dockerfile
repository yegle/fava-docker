# we use SOURCE_BRANCH to indicate the fava version.
ARG SOURCE_BRANCH=master
ARG FAVA_VERSION=${SOURCE_BRANCH}
ARG BEANCOUNT_VERSION=2.2.1
ARG NODE_BUILD_IMAGE=10.16.0-stretch
ARG PYTHON_BUILD_IMAGE=3.7.3-stretch
ARG PYTHON_BASE_IMAGE=3.7.3-slim
ARG PYTHON_DIR=/usr/local/lib/python3.7/site-packages

FROM node:${NODE_BUILD_IMAGE} as node_build_env
ARG FAVA_VERSION

WORKDIR /tmp/build
RUN git clone https://github.com/beancount/fava
WORKDIR /tmp/build/fava
RUN git checkout ${FAVA_VERSION}
RUN make
RUN make mostlyclean

FROM python:${PYTHON_BUILD_IMAGE} as build_env
ARG BEANCOUNT_VERSION
ARG PYTHON_DIR

ENV BEANCOUNT_URL https://bitbucket.org/blais/beancount/get/${BEANCOUNT_VERSION}.tar.gz

RUN apt-get update
RUN apt-get install -y build-essential libxml2-dev libxslt-dev

WORKDIR /tmp/build

# collect wheels for beancount
RUN curl -J -L ${BEANCOUNT_URL} -o beancount-${BEANCOUNT_VERSION}.tar.gz
RUN tar xvf beancount-${BEANCOUNT_VERSION}.tar.gz
RUN python3 -mpip install ./beancount-*

# collect wheels for fava
COPY --from=node_build_env /tmp/build/fava /tmp/build/fava
RUN python3 -mpip install ./fava

RUN find ${PYTHON_DIR} -name *.so -print0|xargs -0 strip -v
RUN find ${PYTHON_DIR} -name __pycache__ -exec rm -rf -v {} +

FROM python:${PYTHON_BASE_IMAGE}
ARG PYTHON_DIR
COPY --from=build_env ${PYTHON_DIR} ${PYTHON_DIR}
COPY --from=build_env /usr/local/bin/fava /usr/local/bin/fava

# Default fava port number
EXPOSE 5000

ENV BEANCOUNT_INPUT_FILE ""
ENV FAVA_OPTIONS "-H 0.0.0.0"

CMD fava ${FAVA_OPTIONS} ${BEANCOUNT_INPUT_FILE}

ARG FAVA_VERSION=1.10
ARG BEANCOUNT_VERSION=2.2.1
ARG NODE_BUILD_IMAGE=10.16.0-stretch
ARG PYTHON_BUILD_IMAGE=3.7.3-stretch
ARG PYTHON_BASE_IMAGE=3.7.3-slim
ARG PYTHON_DIR=/usr/local/lib/python3.7/site-packages

FROM node:${NODE_BUILD_IMAGE} as node_build_env
ARG FAVA_VERSION
ENV FAVA_URL https://github.com/beancount/fava/archive/v${FAVA_VERSION}.tar.gz

WORKDIR /tmp/build
RUN curl -J -L -O ${FAVA_URL}
run tar xvf fava-${FAVA_VERSION}.tar.gz
RUN make -C ./fava-${FAVA_VERSION}
RUN make -C ./fava-${FAVA_VERSION} mostlyclean
RUN echo "Version: ${FAVA_VERSION}" > ./fava-${FAVA_VERSION}/PKG-INFO

FROM python:${PYTHON_BUILD_IMAGE} as build_env
ARG BEANCOUNT_VERSION
ARG FAVA_VERSION
ARG PYTHON_DIR

ENV BEANCOUNT_URL https://bitbucket.org/blais/beancount/get/${BEANCOUNT_VERSION}.tar.gz

RUN apt-get update
RUN apt-get install -y build-essential libxml2-dev libxslt-dev

WORKDIR /tmp/build

# collect wheels for beancount
RUN curl -J -L ${BEANCOUNT_URL} -o beancount-${BEANCOUNT_VERSION}.tar.gz
RUN tar xvf beancount-${BEANCOUNT_VERSION}.tar.gz
RUN python3 -mpip wheel ./beancount-* --wheel-dir /wheelhouse

# collect wheels for fava
COPY --from=node_build_env /tmp/build/fava-${FAVA_VERSION} /tmp/build/fava-${FAVA_VERSION}
RUN ls /tmp/build
RUN python3 -mpip wheel ./fava-${FAVA_VERSION} --wheel-dir /wheelhouse

# install everything from wheels
RUN python3 -mpip install --no-index --find-links /wheelhouse fava

RUN find ${PYTHON_DIR} -name *.so -print0|xargs -0 strip -v
RUN find ${PYTHON_DIR} -name __pycache__ -exec rm -rf -v {} +

FROM python:${PYTHON_BASE_IMAGE}
ARG PYTHON_DIR
COPY --from=build_env ${PYTHON_DIR} ${PYTHON_DIR}
COPY --from=build_env /usr/local/bin/fava /usr/local/bin/fava

# Default fava port number
EXPOSE 5000

CMD fava $FAVA_OPTIONS $BEANCOUNT_INPUT_FILE

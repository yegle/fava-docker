ARG BEANCOUNT_VERSION=2.2.1
ARG NODE_BUILD_IMAGE=10.16.0-stretch
ARG PYTHON_DIR=/usr/local/lib/python3.5/dist-packages

FROM node:${NODE_BUILD_IMAGE} as node_build_env
ARG SOURCE_BRANCH
ENV FAVA_VERSION=${SOURCE_BRANCH:-v1.10}

WORKDIR /tmp/build
RUN git clone https://github.com/beancount/fava
WORKDIR /tmp/build/fava
RUN git checkout ${FAVA_VERSION}
RUN make
RUN make mostlyclean

FROM debian:stable as build_env
ARG BEANCOUNT_VERSION
ARG PYTHON_DIR

ENV BEANCOUNT_URL https://bitbucket.org/blais/beancount/get/${BEANCOUNT_VERSION}.tar.gz

RUN apt-get update
RUN apt-get install -y build-essential libxml2-dev libxslt-dev curl \
        python3 libpython3-dev python3-pip git

WORKDIR /tmp/build

RUN pip3 install -U setuptools
RUN pip3 install m3-cdecimal

RUN curl -J -L ${BEANCOUNT_URL} -o beancount-${BEANCOUNT_VERSION}.tar.gz
RUN tar xvf beancount-${BEANCOUNT_VERSION}.tar.gz
RUN pip3 install ./beancount-*

COPY --from=node_build_env /tmp/build/fava /tmp/build/fava
RUN ls ./fava/.git
RUN pip3 install ./fava

RUN find ${PYTHON_DIR} -name *.so -print0|xargs -0 strip -v
RUN find ${PYTHON_DIR} -name __pycache__ -exec rm -rf -v {} +

# Note: this is python3.5, which barely meet the requirement of beancount. We
# will need to update to newer version once it's supported.
FROM gcr.io/distroless/python3
ARG PYTHON_DIR
COPY --from=build_env ${PYTHON_DIR} ${PYTHON_DIR}
COPY --from=build_env /usr/local/bin/fava /usr/local/bin/fava
# list of beancount binaries available in
# https://bitbucket.org/blais/beancount/src/default/setup.py
COPY --from=build_env \
            /usr/local/bin/bean-bake \
            /usr/local/bin/bean-check \
            /usr/local/bin/bean-doctor \
            /usr/local/bin/bean-example \
            /usr/local/bin/bean-format \
            /usr/local/bin/bean-price \
            /usr/local/bin/bean-query \
            /usr/local/bin/bean-report \
            /usr/local/bin/bean-sql \
            /usr/local/bin/bean-web \
            /usr/local/bin/bean-identify \
            /usr/local/bin/bean-extract \
            /usr/local/bin/bean-file \
            /usr/local/bin/treeify \
            /usr/local/bin/upload-to-sheets \
            /usr/local/bin/

# Default fava port number
EXPOSE 5000

ENV BEANCOUNT_FILE ""

# Required by Click library.
# See https://click.palletsprojects.com/en/7.x/python3/
ENV LC_ALL "C.UTF-8"
ENV LANG "C.UTF-8"

ENTRYPOINT ["/usr/local/bin/fava", "-H", "0.0.0.0"]

ARG BEANCOUNT_VERSION=2.3.4
ARG NODE_BUILD_IMAGE=10.17.0-buster

FROM node:${NODE_BUILD_IMAGE} as node_build_env
ARG SOURCE_BRANCH
ENV FAVA_VERSION=${SOURCE_BRANCH:-v1.20.1}

WORKDIR /tmp/build
RUN git clone https://github.com/beancount/fava

WORKDIR /tmp/build/fava
RUN git checkout ${FAVA_VERSION}
RUN make
RUN make mostlyclean

FROM debian:buster as build_env
ARG BEANCOUNT_VERSION

RUN apt-get update
RUN apt-get install -y build-essential libxml2-dev libxslt-dev curl \
        python3 libpython3-dev python3-pip git python3-venv


ENV PATH "/app/bin:$PATH"
RUN python3 -mvenv /app
RUN pip3 install -U pip setuptools
COPY --from=node_build_env /tmp/build/fava /tmp/build/fava

WORKDIR /tmp/build
RUN git clone https://github.com/beancount/beancount

WORKDIR /tmp/build/beancount
RUN git checkout ${BEANCOUNT_VERSION}

RUN CFLAGS=-s pip3 install -U /tmp/build/beancount
RUN pip3 install -U /tmp/build/fava

RUN pip3 uninstall -y pip

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

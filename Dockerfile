ARG BEANCOUNT_VERSION=3.0.0
ARG FAVA_VERSION=v1.28

FROM node:alpine as node_build_env
RUN apk add python3 py3-pip python3-dev build-base git
WORKDIR /tmp/build
RUN git clone https://github.com/beancount/fava
RUN git clone https://github.com/beancount/beancount
WORKDIR /tmp/build/fava
RUN git checkout ${FAVA_VERSION}
WORKDIR /tmp/build/beancount
RUN git checkout ${BEANCOUNT_VERSION}
WORKDIR /tmp/build/
RUN python3 -mvenv /app
RUN . /app/bin/activate && CFLAGS=-s pip3 install -U /tmp/build/beancount && pip3 install -U /tmp/build/fava
# RUN apk del jansson zstd-libs binutils libmagic file libgomp libatomic gmp isl26 mpfr4 mpc1 gcc libstdc++-dev musl-dev g++ make fortify-headers patch build-base libbz2 libexpat libffi gdbm xz-libs mpdecimal ncurses-terminfo-base libncursesw libpanelw readline sqlite-libs python3 pyc py3-setuptools-pyc py3-pip-pyc py3-parsing py3-parsing-pyc py3-packaging-pyc python3-pyc py3-packaging py3-setuptools py3-pip pkgconf python3-dev ca-certificates brotli-libs c-ares libunistring libidn2 nghttp2-libs libpsl libcurl pcre2 git git-init-template
# RUN rm -rf /tmp/build
# RUN find /app -name __pycache__ -exec rm -rf -v {} +

# FROM python:3.12.6-alpine
# COPY --from=node_build_env /app /app
# RUN apk add tree
# RUN ls -la /app/bin

# Default fava port number
EXPOSE 5000
ENV BEANCOUNT_FILE "/bean/main.bean"
ENV FAVA_HOST "0.0.0.0"
ENV PATH "/app/bin:$PATH"

ENTRYPOINT ["fava"]

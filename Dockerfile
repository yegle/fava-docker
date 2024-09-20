ARG BEANCOUNT_VERSION=3.0.0
ARG FAVA_VERSION=v1.28

FROM node:22-alpine3.20 as node_build_env
RUN apk add --no-cache python3 py3-pip python3-dev build-base git
WORKDIR /tmp/build
RUN git clone https://github.com/beancount/fava
RUN git clone https://github.com/beancount/beancount
WORKDIR /tmp/build/fava
RUN git checkout ${FAVA_VERSION}
WORKDIR /tmp/build/beancount
RUN git checkout ${BEANCOUNT_VERSION}
WORKDIR /tmp/build/
RUN python3 -mvenv /app
# ADD requirements.txt .
# RUN . /app/bin/activate && pip3 install --require-hashes -U -r requirements.txt
# RUN . /app/bin/activate && pip3 install git+https://github.com/beancount/beanprice.git@41576e2ac889e4825e4985b6f6c56aa71de28304
# RUN . /app/bin/activate && pip3 install git+https://github.com/andreasgerstmayr/fava-portfolio-returns.git@152a1057c065c2ecd0e91ef62c9d73081f833329
WORKDIR /tmp/build/beancount
RUN . /app/bin/activate && CFLAGS=-s pip3 install -U /tmp/build/beancount
WORKDIR /tmp/build/fava
RUN . /app/bin/activate && pip3 install -U /tmp/build/fava
RUN rm -rf .*cache && \
    rm -rf .eggs && \
    rm -rf .tox && \
    rm -rf build && \
    rm -rf dist && \
    rm -rf frontend/node_modules && \
    find . -type f -name '*.py[c0]' -delete && \
    find . -type d -name "__pycache__" -delete
RUN apk del jansson zstd-libs binutils libmagic file libgomp libatomic gmp isl26 mpfr4 mpc1 gcc libstdc++-dev musl-dev g++ make fortify-headers patch build-base libbz2 libexpat libffi gdbm xz-libs mpdecimal ncurses-terminfo-base libncursesw libpanelw readline sqlite-libs python3 pyc py3-setuptools-pyc py3-pip-pyc py3-parsing py3-parsing-pyc py3-packaging-pyc python3-pyc py3-packaging py3-setuptools py3-pip pkgconf python3-dev ca-certificates brotli-libs c-ares libunistring libidn2 nghttp2-libs libpsl libcurl pcre2 git git-init-template
RUN rm -rf /tmp/build
RUN find /app -name __pycache__ -exec rm -rf -v {} +

FROM alpine:3.20
RUN apk add --no-cache py3-pip
COPY --from=node_build_env /app /app

# Default fava port number
EXPOSE 5000
ENV BEANCOUNT_FILE "/bean/main.bean"
ENV FAVA_HOST "0.0.0.0"
ENV PATH "/app/bin:$PATH"

ENTRYPOINT ["fava"]

FROM python:3.6.5-alpine3.7 as build_env

ENV FINGERPRINT "sha256:32:12:90:9a:70:64:82:1c:5b:52:cc:c3:0a:d0:79:db:e1:a8:62:1b:9a:9a:4c:f4:72:40:1c:a7:3a:d3:0a:8c"
ENV BUILDDEPS "libxml2-dev libxslt-dev gcc musl-dev mercurial git nodejs make g++"
# Short python version.
ENV PV "3.6"

WORKDIR /root
RUN apk add --update ${BUILDDEPS}

RUN hg clone --config hostsecurity.bitbucket.org:fingerprints=${FINGERPRINT} https://bitbucket.org/blais/beancount
RUN echo "Beancount version:" && cd beancount && hg log -l1

RUN git clone https://github.com/beancount/fava.git
RUN echo "Fava version:" && cd fava && git log -1

RUN echo "Deleting symlink files as they will cause docker build error" && find ./ -type l -delete -print

RUN echo "Install Beancount..."
RUN python3 -mpip install ./beancount

RUN echo "Install Fava..."
RUN make -C fava
RUN make -C fava mostlyclean
RUN python3 -mpip install ./fava

RUN echo "Strip .so files to reduce image size:"
RUN find /usr/local/lib/python${PV}/site-packages -name *.so -print0|xargs -0 strip -v
RUN echo "Remove unused files to reduce image size:"
RUN find /usr/local/lib/python${PV} -name __pycache__ -delete -print
RUN find /usr/local/lib/python${PV} -name '*.dist-info' -delee -print


FROM python:3.6.5-alpine3.7
ENV PV "3.6"
ENV BEANCOUNT_INPUT_FILE ""
ENV FAVA_OPTIONS "-H 0.0.0.0"
COPY --from=build_env /usr/local/lib/python${PV}/site-packages /usr/local/lib/python${PV}/site-packages
COPY --from=build_env /usr/local/bin/fava /usr/local/bin

# Default fava port number
EXPOSE 5000

CMD fava $FAVA_OPTIONS $BEANCOUNT_INPUT_FILE

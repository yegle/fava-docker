FROM python:3.6.5-alpine3.7 as build_env

ENV BEANCOUNT_INPUT_FILE ""
ENV FAVA_OPTIONS "-H 0.0.0.0"
ENV FINGERPRINT "sha256:32:12:90:9a:70:64:82:1c:5b:52:cc:c3:0a:d0:79:db:e1:a8:62:1b:9a:9a:4c:f4:72:40:1c:a7:3a:d3:0a:8c"
ENV BUILDDEPS "libxml2-dev libxslt-dev gcc musl-dev mercurial git nodejs make g++"
# Short python version.
ENV PV "3.6"

WORKDIR /root
RUN apk add --update ${BUILDDEPS} \
        && hg clone --config hostsecurity.bitbucket.org:fingerprints=$FINGERPRINT https://bitbucket.org/blais/beancount \
        && (cd beancount && hg log -l1) \
        && git clone https://github.com/beancount/fava.git \
        && (cd fava && git log -1) \
        && echo "Deleting symlink files as they will cause docker build error" \
        && find ./ -type l -delete -print \
        && python3 -mpip install ./beancount \
        && make -C fava \
        && make -C fava mostlyclean \
        && python3 -mpip install ./fava \
        && echo "strip .so files:" \
        && find /usr/local/lib/python${PV}/site-packages -name *.so -print0|xargs -0 strip -v \
        && echo "remove __pycache__ directories" \
        && find /usr/local/lib/python${PV} -name __pycache__ -exec rm -rf -v {} + \
        && find /usr/local/lib/python${PV} -name '*.dist-info' -exec rm -rf -v {} +


FROM python:3.6.5-alpine3.7
ENV PV "3.6"
COPY --from=build_env /usr/local/lib/python${PV}/site-packages /usr/local/lib/python${PV}/site-packages
COPY --from=build_env /usr/local/bin/fava /usr/local/bin

# Default fava port number
EXPOSE 5000

CMD fava $FAVA_OPTIONS $BEANCOUNT_INPUT_FILE

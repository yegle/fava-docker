FROM python:3.6.5-alpine3.7

ENV BEANCOUNT_INPUT_FILE ""
ENV FAVA_OPTIONS "-H 0.0.0.0"
ENV FINGERPRINT "70:a7:44:ea:a9:ea:e8:69:16:ea:12:00:35:a9:a6:0e:ae:38:8e:f8"
ENV BUILDDEPS "libxml2-dev libxslt-dev gcc musl-dev mercurial git nodejs make g++"
ENV RUNDEPS "libxml2 libxslt"

RUN cd /root \
        && apk add --update $BUILDDEPS $RUNDEPS \
        && hg clone --config hostfingerprints.bitbucket.org=$FINGERPRINT https://bitbucket.org/blais/beancount \
        && (cd beancount && hg log -l1) \
        && find ./beancount/.hg -type l -delete \
        && python3 -mpip install ./beancount \
        && git clone https://github.com/beancount/fava.git \
        && (cd fava && git log -1) \
        && make -C fava \
        && make -C fava mostlyclean \
        && rm fava/docs/changelog.rst \
        && python3 -mpip install ./fava \
        && python3 -mpip uninstall --yes pip \
        && find /usr/local/lib/python3.?/site-packages -name *.so -print0|xargs -0 strip -v \
        && apk del $BUILDDEPS \
        && rm -rf /var/cache/apk /tmp /root \
        && find /usr/local/lib/python3.? -name __pycache__ -print0|xargs -0 rm -rf \
        && find /usr/local/lib/python3.? -name *.pyc -print0|xargs -0 rm -f


# Default fava port number
EXPOSE 5000

CMD fava $FAVA_OPTIONS $BEANCOUNT_INPUT_FILE

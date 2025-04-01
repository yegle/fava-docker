FROM python:3.14.0a6

RUN apt-get update
RUN apt-get install -y pipx

RUN mkdir /app
RUN chown 1000:1000 /app
USER 1000:1000

ENV PIPX_HOME="/app"
ENV PIPX_BIN_DIR="/app/bin"
RUN pipx install beancount==3.1.0
RUN pipx install beanquery==v0.2.0
RUN pipx install fava==v1.30.2

ENV BEANCOUNT_FILE=""

ENV FAVA_HOST="0.0.0.0"
ENV PATH=/app/bin:$PATH

ENTRYPOINT ["fava"]
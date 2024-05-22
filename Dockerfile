FROM debian:bullseye as build_env
ARG BEANCOUNT_VERSION

RUN apt-get update
RUN apt-get install -y build-essential libxml2-dev libxslt-dev curl \
        python3 libpython3-dev python3-pip git python3-venv

ENV PATH "/app/bin:$PATH"
RUN python3 -mvenv /app
ADD requirements.txt .
RUN pip3 install -U -r requirements.txt

RUN pip3 uninstall -y pip
RUN find /app -name __pycache__ -exec rm -rf -v {} +

#Distroless is too limited for my use.
# I use Python
FROM python:3.12.3-bullseye
COPY --from=build_env /app /app
RUN apt-get update
RUN apt-get install -y git nano poppler-utils wget

# Default fava port number
EXPOSE 5000

ENV BEANCOUNT_FILE ""

ENV FAVA_HOST "0.0.0.0"
ENV PATH "/app/bin:$PATH"
ENV PYTHONPATH "/myData/myTools:$PYTHONPATH"

ENTRYPOINT ["fava"]

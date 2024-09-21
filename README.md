# fava-docker

A Dockerfile for beancount-fava


## Usage Example

You can get started creating a container from this image, you can either use docker-compose or the docker cli.

Assuming you have `example.bean` in the current directory:

### Docker Cli

```bash
docker run -d \
    --name=fava \
    -v $PWD:/bean \
    -e BEANCOUNT_FILE=/bean/example.bean \
    -p 5000:5000 \
    --restart unless-stopped \
    ghcr.io/duquewu/fava-docker
```

### Docker Compose

```yml
---
version: "3.0"
services:
  fava:
    container_name: fava
    image: ghcr.io/duquewu/fava-docker
    ports:
      - 5000:5000
    environment:
      - BEANCOUNT_FILE=/bean/example.beancount
    volumes:
      - ${PWD}/:/bean
    restart: unless-stopped
```

## Environment Variable

| Parameter | Value |
| :----: | --- |
| `BEANCOUNT_FILE` | path to your beancount file. Default to empty string. |

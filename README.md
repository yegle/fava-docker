# fava-docker

A Dockerfile for beancount-fava , based on https://github.com/yegle/fava-docker but with additional features:
- smart-importer
- fava-investor
- Beanprice
- tariochbctools
- poppler-utils
- git
- nano
- fava dashboards

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
    grostim/fava-docker
```

### Docker Compose

```yml
---
version: "3.0"
services:
  fava:
    container_name: fava
    image: grostim/fava-docker
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

## Note on auto build

The [docker image](https://hub.docker.com/r/yegle/fava) was switched
from build by Docker Hub to Github Actions. The image label pattern is
changed: instead of labeled `version-1.xx` it's now labeled `v1.xx`.

You can check the auto build logs at https://github.com/yegle/fava-docker/actions.

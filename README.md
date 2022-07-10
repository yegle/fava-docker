# fava-docker
A Dockerfile for beancount-fava

## Environment Variable

- `BEANCOUNT_FILE`: path to your beancount file. Default to empty string.

## Usage Example

```
# assume you have example.bean in the current directory
docker run -v $PWD:/bean -e BEANCOUNT_FILE=/bean/example.bean yegle/fava
```

## Note on auto build

The [docker image](https://hub.docker.com/r/yegle/fava) was switched
from build by Docker Hub to Github Actions. The image label pattern is
changed: instead of labeled `version-1.xx` it's now labeled `v1.xx`.

You can check the auto build logs at
https://github.com/yegle/fava-docker/actions

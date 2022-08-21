# fava-docker

A Dockerfile for beancount-fava

## Environment Variable

- `BEANCOUNT_FILE`: path to your beancount file. Default to empty string.

## Usage Example

```bash
# assume you have example.bean in the current directory
docker run -v $PWD:/bean -e BEANCOUNT_FILE=/bean/example.bean yegle/fava
```

NOTE: The command above does not expose the Fava HTTP server port outside of Docker's internal network.
This allows you [to use your own reverse proxy](https://github.com/beancount/fava/tree/main/contrib/docker#advanced).
If you do want to expose the service without using a reverse proxy for local testing, you must add `-p 5000:5000`
to access Fava on http://localhost:5000.

## Note on auto build

The [docker image](https://hub.docker.com/r/yegle/fava) was switched
from build by Docker Hub to Github Actions. The image label pattern is
changed: instead of labeled `version-1.xx` it's now labeled `v1.xx`.

You can check the auto build logs at https://github.com/yegle/fava-docker/actions.

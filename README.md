# fava-docker
A Dockerfile for beancount-fava

## Environment Variable

- `BEANCOUNT_INPUT_FILE`: path to your beancount file. Default to empty string.
- `FAVA_OPTIONS`: options to `fava` binary. Default to `-p 5555 -H
  0.0.0.0`. NOTE: if you want to change port number, remember to add `-H
  0.0.0.0`.

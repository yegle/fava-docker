# fava-docker
A Dockerfile for beancount-fava

## Environment Variable

- `BEANCOUNT_INPUT_FILE`: path to your beancount file. Default to empty string.
- `FAVA_OPTIONS`: options to `fava` binary. Default to `-H 0.0.0.0`.
  NOTE: if you want to add any options here, remember to add `-H
  0.0.0.0`, otherwise you won't be able to access fava via port mapping.

# fava-docker
A Dockerfile for beancount-fava

## Environment Variable

- `BEANCOUNT_FILE`: path to your beancount file. Default to empty string.

## Usage Example

```
# assume you have example.bean in the current directory
docker run -v $PWD:/bean -e BEANCOUNT_FILE=/bean/example.bean yegle/fava
```

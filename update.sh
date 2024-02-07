#!/usr/bin/env bash

err() { echo $1; exit 1; }

if [[ $# -ne 0 ]]
then
    BEANCOUNT_VERSION=$1
else
    BEANCOUNT_VERSION=$(git branch --show-current)
fi

if [[ ${BEANCOUNT_VERSION} == "master" ]]
then
    err "Please run update in a non-master branch"
elif ! [[ ${BEANCOUNT_VERSION} =~ v.* ]]
then
    err "Beancount version should be a string matching /v.*/, got '${BEANCOUNT_VERSION}'"
fi

BEANCOUNT_VERSION=${BEANCOUNT_VERSION#v}

REQUIREMENTS_TXT="https://raw.githubusercontent.com/beancount/beancount/${BEANCOUNT_VERSION}/requirements.txt"

TMPFILE=$(mktemp)

curl -o ${TMPFILE} ${REQUIREMENTS_TXT}

pip-compile ${TMPFILE}

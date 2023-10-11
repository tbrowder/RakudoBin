#!/bin/bash

KEYS="https://rakudo.org/keys";

if [[ -z $1 ]]; then
    echo "Usage: $0 go"
    echo
    echo "  Download keys.";
    exit
fi

curl -1sLf $KEYS

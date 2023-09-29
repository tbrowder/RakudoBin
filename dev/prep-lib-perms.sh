#!/bin/bash

LIBDIR="../lib"

if [[ -z $1 ]]; then
    echo "Usage: $0 go"
    echo "  (as root)"
    echo "  With system calls 'chmod' and 'chown', ensures '$LIBDIR' can be used by a normal user."
    exit
fi

# run as root user
if [[ $EUID != 0 ]]; then 
    echo "Please run as root"
    exit
fi

chown -R tbrowde $LIBDIR
chmod    766 $LIBDIR
chmod    766 $LIBDIR/.precomp


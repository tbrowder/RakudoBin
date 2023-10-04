#!/bin/bash

if [[ -z $1 ]]; then
    echo "Usage: $0 go"
    echo "  (as an ordinary user)"
    echo "  Removes the user's .raku, .zef, and zef."
    exit
fi

if [[ $EUID == 0 ]]; then 
    echo "Please run as an ordinary user"
    exit
fi

#echo "DEBUG exit"
#exit

# clean out my raku and zef stuff
rm -rf ~/.raku ~/.zef ~/zef

echo "Removal of user '$USER's .raku and .zef is complete."

#!/bin/bash

BASEDIR=$(dirname $0)
FILETOCOPY=$BASEDIR"/.filetocopy"
FILEDIR=$BASEDIR"/.home"

mkdir -p $FILEDIR

if [ -f $FILETOCOPY ]
then
    rm -rf "$FILEDIR/*"
    while read line
    do
        eval line="$( cut -d '#' -f 1 <<< "$line" )";
        line=${line// /}
        if [ ! -z "$line" ]
        then
            if [ -f $line ]
            then
            cp $line "$FILEDIR/"
            fi
        fi
    done <  $FILETOCOPY
fi

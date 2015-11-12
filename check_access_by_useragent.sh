#!/bin/bash

if [ -z $1 ]
then
    echo "Usage: $0 path/2/useragent.list"
    exit 1
fi

cat "$1" | while read line
do
    res=`wget -q linuxhub.ru -U "$line" -S -O - 2>&1 | grep HTTP`
    echo $line - $res
done
exit 0


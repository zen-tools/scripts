#!/bin/bash
if [ -z $1 ]
then
    echo "Usage: $0 path/2/proxy.list"
    exit 1
fi

cat "$1" | while read line
do
    host=`echo $line | sed 's/:[0-9]*.//'`
    if [ ! -z `ping  -w1 -c1 $host > /dev/null && echo 'alive'` ]
    then
        test=`http_proxy="$line" wget -w2 --timeout=0 --read-timeout=0 --connect-timeout=0 --tries=0 myip.ru -O - -q 2> /dev/null \
        | w3m -T text/html -dump | egrep '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | xargs`
    fi

    if [ ! -z $test ]
    then
        echo $line
    else
        echo $line " - broken"
    fi
done
exit 0


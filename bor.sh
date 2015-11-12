#!/usr/bin/env bash

bor () {
    echo;
    wget http://bash.im/forweb/ -q -O - \
    | sed "s/' + '//g" \
    | iconv -f cp1251 \
    | w3m -T text/html -dump \
    | sed '1,2d;N;$!P;$!D;$d;';
    echo -e "\r";
}

bor;

exit 0;


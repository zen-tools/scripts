#!/usr/bin/env bash

ibash () {
    echo;
    wget http://ibash.org.ru/random.php -O- 2>/dev/null \
    | w3m -T text/html -dump \
    | sed '1,6d;' \
    | sed -n -e :a -e '1,6!{P;N;D;};N;ba';
    echo;
}

ibash;

exit 0;


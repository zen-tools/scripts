#!/usr/bin/env bash

function declOfNum() {
    test $# -eq 1 || {
        echo "ERROR: declOfNum function expect 1 params" 1>&2;
        exit 1;
    };

    local NUM="$1";
    (( ( $NUM % 100 ) > 4 && ( $NUM % 100 ) < 20 )) && {
        echo 2;
    } || {
        local CASES=( 2 0 1 1 1 2 );
        local i=$(( ($NUM % 10) < 5 ? ($NUM % 10) : 5 ));
        echo ${CASES[i]};
    }
    return 0;
}

TRIES="$1";
STRINGS=(
    "Осталась _{{NUM}} попытка"
    "Осталось _{{NUM}} попытки"
    "Осталось _{{NUM}} попыток"
);
IDX="$(declOfNum $TRIES)" || exit 2;

(( ${#STRINGS[$IDX]} > 0 )) && {
    echo ${STRINGS[$IDX]} | sed "s/_{{NUM}}/$TRIES/g";
} || {
    echo "ERROR: Translation was not found" 1>&2;
    exit 3;
};

exit 0;


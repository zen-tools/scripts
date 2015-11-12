#!/usr/bin/env bash

function vote() {
    test "$#" -le "2" && {
        echo "You should set subject and at least two option for polling";
        echo "$0 subj option1 option2 optionN";
        return 1;
    }

    # Todays subject
    echo "$1";

    # Collect data
    while shift && (($#))
    do
        unset VOTES;
        for i in $(seq 1 $(( 1 + $RANDOM % 10 )) );
        do
            let VOTES=VOTES+$(( $RANDOM % 10 ));
        done;
        printf "%-15s\t%s\n" "$1" "$VOTES";
    done;
}

vote $@;


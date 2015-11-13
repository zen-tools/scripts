#!/usr/bin/env bash

# Is unsigned int?
function is_unsigned_int () {
    test $(expr match "$1" "^[0-9]*$") -gt 0 \
    && return 0 \
    || return 1 ;
}

function progressbar () {
    # Value in percent. Default value is 0
    local VALUE="${1:-0}";

    # Progress bar width. Default size is width of terminal
    local MAX_WIDTH="${PROGRESSBAR_WIDTH:-$(( $(tput cols) - 7 ))}";

    # Return if value invalid
    is_unsigned_int "$VALUE" 	 || return 1;
    is_unsigned_int "$MAX_WIDTH" || return 2;
    test "$VALUE" -gt 100    	 && return 3;

    # Processing
    local BEGIN=${PROGRESSBAR_BEGIN:-[};
    local USED=${PROGRESSBAR_USED:-=};
    local FREE=${PROGRESSBAR_FREE:--};
    local CURSOR=${PROGRESSBAR_CURSOR:->};
    local END=${PROGRESSBAR_END:-]};
    local CUR=$(awk "BEGIN {print int(${MAX_WIDTH:-0}/100*${VALUE:-0})}");

    # Draw progressbar
    echo -n "$BEGIN";

    while [[ "$POS" -lt "$MAX_WIDTH" ]]
    do
        if [[ "$POS" -lt "$CUR" ]]
        then # Draw used space
            echo -n "$USED";
        elif [[ "$POS" -gt "$CUR" ]]
        then # Draw free space
            echo -n "$FREE";
        else # Draw cursor
            echo -n "$CURSOR";
        fi
        let POS+=1;
    done

    echo -n "$END";
    printf "%4d%%\n" "$VALUE";

    # Return a successful code
    return 0;
}

progressbar $@;

exit $?;


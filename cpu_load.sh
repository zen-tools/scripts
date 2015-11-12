#!/bin/bash
############################################################
# Linux CPU Usage
#
# Fork: Poltavchenko Dmitriy (http://linuxhub.ru)
# Author: Moises P. Sena (http://moisespsena.com)
# Original Author: Paul Colby (http://colby.id.au)
#
# no rights reserved :)
############################################################

PREV_TOTAL=0;
PREV_IDLE=0;

cpu_load() {
    local CPU=( $(cat /proc/stat | grep '^cpu ') ); # Get the total CPU statistics.
    unset CPU[0]; # Discard the "cpu" prefix.
    local IDLE="${CPU[4]}"; # Get the idle CPU time.

    # Calculate the total CPU time.
    local TOTAL=0;
    for VALUE in "${CPU[@]}"
    do
        let "TOTAL=$TOTAL+$VALUE";
    done

    unset CPU;
    sleep .5;

    local CPU=( $(cat /proc/stat | grep '^cpu ') ); # Get the total CPU statistics.
    unset CPU[0]; # Discard the "cpu" prefix.
    local PREV_IDLE="${CPU[4]}"; # Get the idle CPU time.

    # Calculate the total CPU time.
    local PREV_TOTAL=0;
    for VALUE in "${CPU[@]}"
    do
        let "PREV_TOTAL=$PREV_TOTAL+$VALUE";
    done

    # Calculate the CPU usage since we last checked.
    let "DIFF_IDLE=$IDLE-$PREV_IDLE";
    let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL";
    let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10";

    echo "$DIFF_USAGE";
}

VALUE=$(cpu_load);
POS=0;
MAX=50;
CUR=$(echo "scale=1; $MAX/100*$VALUE" | bc | awk -F. '{print $1}')

echo -n "[";

while
let POS+=1
[[ $POS -lt $MAX ]]
do
    test "$POS" -lt "$CUR" && echo -n "#" || echo -n "=";
done

echo "] $VALUE%";

exit 0;


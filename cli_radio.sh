#!/usr/bin/env bash

PLAYER="cvlc";

# Radio Station List
RSL=(
    "Шансон=http://217.20.164.170:8002"
    "Русское Радио=http://online-rusradio.tavrmedia.ua/RusRadio"
);

### FUNCTION LIST ###
function interrupted () {
    stop;
    reset;
    exit 0;
}

function stop () {
    kill -SIGTERM $PROC_ID &> /dev/null;
}

function play () {
    stop;
    echo ${RSL[$POS]%=*};
    $PLAYER "${RSL[$POS]#*=}" &> /dev/null & PROC_ID=$!;
}

### MAIN LOOP ###
unset PROC_ID;
trap interrupted INT;

if [[ ${#RSL[@]} == 0 ]]
then
    echo "Check your list of radio stations";
    exit 1;
fi

POS=0;

while
read -s -n1 BUFF
[[ -n $BUFF ]]
do
    case $BUFF in
        N|n) # Next
            POS=$(($POS+1));
            test $POS -ge ${#RSL[@]} && POS=0;
            play;
            ;;
        B|b) # Back
            POS=$(($POS-1));
            test $POS -lt 0 && POS=$((${#RSL[@]}-1));
            play;
            ;;
        S|s) # Stop
            stop;
            ;;
        P|p) # Play
            play;
            ;;
        Q|q) # Quit
            stop;
            exit 0;
            ;;
    esac
done

# Clean up
stop;

exit 0;


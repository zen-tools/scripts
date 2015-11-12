#!/bin/bash

PASSWORD=""

while
read -s -n1 BUFF
[[ -n $BUFF ]]
do
    # 127 - backspace ascii code 
    if [[ `printf "%d\n" \'$BUFF` == 127 ]]
    then
        PASSWORD="${PASSWORD%?}"
        echo -en "\b \b"
    else
        PASSWORD=$PASSWORD$BUFF
        echo -en "*"
    fi
done

echo
echo $PASSWORD

exit 0


#!/bin/bash

function message () {
    notify-send -t 10000 -i "$APP_ICON" "$APP_NAME" "$@" &> /dev/null \
    || echo "$@" 1>&2;
}

# Username
LOGIN="test";
# Password hash. echo -en "password" | md5sum
PASS="b59c67bf196a4758191e42f76670ceba";
APP_ICON="info";
APP_NAME="TeNeT";
# Alert when balance lower than min value
MIN="10";
# Repeat request if has network troubles
TRIES="3";
# Timeout before new request
TIME_OUT="1m";
# TeNeT API URL
URL="https://stats.tenet.ua/utl/!gadgapi.ls_state_evpkt";
# POST query
POST="login=$LOGIN&md5pass=$PASS&t=$(date +%s)";
# Parameters of Wget
OPT="--tries=0 --timeout=10 -q";
# Target tag from TeNet response
TAG="saldo";

# Get balance
while [[ -z "$COST" && $i -lt $TRIES ]]
do
    COST=$(wget $OPT $URL --post-data $POST -O - \
        | awk -F'>|<' '{print $23}' \
        | tr ',' '.'
    );
    test -z "$COST" && sleep $TIME_OUT;
    let i++;
done

# If network error or bad username/password
if [[ -z "$COST" ]]
then
    message "Ошибка: не удалось получить состояние счета";
    exit 1;
# If has balance and it lower than min value
elif
    echo "$COST" "$MIN" \
    | awk '{if ($1 <= $2) exit 0; else exit 1;}'
then
    DATE=$(date "+%d.%m.%Y");
    message "Баланс на $DATE составляет $COST грн.";
fi

exit 0;


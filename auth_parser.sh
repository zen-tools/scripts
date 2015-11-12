#!/usr/bin/env bash

# Get only 3 days old messages from auth.log

LOG_FILE="/var/log/auth.log";
MIN_DAY=$(date -d "3 days ago" "+%s");

test -r "$LOG_FILE" || {
    echo "$LOG_FILE not found" 1>&2;
    exit 1;
}

BUFFER=();
while read LINE
do
    CUR_DAY=$(echo $LINE | awk '{print $1" "$2}' | xargs -I{} date -d "{}" "+%s");
    test "$CUR_DAY" -gt "$MIN_DAY" && BUFFER+=("$LINE");
done < <(tac $LOG_FILE);

printf "%s\n" "${BUFFER[@]}" | tac;

exit 0;


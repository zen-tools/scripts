#!/usr/bin/env bash

# Ftp user credential and etc..
FTP_USER="login";
FTP_PASS="password";
FTP_HOST="ftp.server.ua";
FTP_PATH="/pub/chatlogs/";

### Local host variables
export TZ="Europe/Kiev";
CHATLOGS_DIR="/home/jabber-bot/chatlogs/linuxhub@conference.xmpp.ru";
SAVE_FILE="/home/jabber-bot/$(basename $0 .sh).save";
TMP_FILE="/tmp/$(date +"%s")_$(basename $0 .sh).tmp";
SCRIPT_DEPS=(
    ncftpput
    md5sum
    date
    grep
    awk
    sed
);

function require () {
    local NF;
    while (($#)); do
        test -z $(which $1 2> /dev/null) && NF+=("$1");
        shift;
    done

    # Return the elements of array what have been not found
    test ${#NF[@]} -ne 0 && {
        echo ${NF[@]} && return 1;
    }

    return 0;
}

function refresh_saves() {
    local FILES=($@);
    test ${#FILES[@]} -gt 0 || return 1;

    # Building a pattern for grep
    local OPTIN;
    for i in ${FILES[@]}; do
        OPTIN="-e $i $OPTIN";
    done

    # Clean up save file
    grep $OPTIN "$SAVE_FILE" > "$TMP_FILE";
    cat "$TMP_FILE" > "$SAVE_FILE";
    unlink "$TMP_FILE";

    return 0;
}

function get_new_hash() {
    local FILE="$1";
    echo $(md5sum "$FILE" | awk '{print $1; exit}');
}

function get_old_hash() {
    test -z "$1" && return 1;
    echo $(awk -v f="$1" 'match($0, f) {print $1; exit};' "$SAVE_FILE");
}

function update_old_hash() {
    local FILE="$1";
    local NEW_MD5="$2";
    grep -q -m 1 "$FILE" "$SAVE_FILE" \
    && sed "s|.*\( .*$FILE\)|$NEW_MD5 \1|g" -i "$SAVE_FILE" \
    || echo "$NEW_MD5  $FILE" >> "$SAVE_FILE";
}

function has_updates() {
    local FILE="$1";
    local OLD_MD5="$(get_old_hash "$FILE")";
    test -r "$FILE" && {
        local NEW_MD5="$(get_new_hash "$FILE")";
        test "$OLD_MD5" == "$NEW_MD5" || {
            # Return new md5 hash
            echo $NEW_MD5;
            # Return true is file must be updated
            return 0;
        }
    }

    return 1;
}

function ftp_sync() {
    local FILE="$1";
    local REMOTE_PATH="$FTP_PATH/$(dirname $FILE | sed "s|$CHATLOGS_DIR/\?||g")";
    ncftpput -m -z -u $FTP_USER -p $FTP_PASS $FTP_HOST $REMOTE_PATH $FILE;
}

### Check script dependency
NOT_FOUND=( $(require "${SCRIPT_DEPS[@]}") ) || {
    echo -e "ERROR: Unresolved dependencies:\n$(printf '%s\n' ${NOT_FOUND[@]})" 1>&2;
    exit 1;
}

### Create array list of files what must be upload if has updates
FILE_LIST=(
    "$CHATLOGS_DIR/$(date --date="yesterday" +%Y/%m/%d).html"
    "$CHATLOGS_DIR/$(date +%Y/%m/%d).html"
);

### Clean up save file
refresh_saves ${FILE_LIST[@]};

### Check even file for updates
for i in ${FILE_LIST[@]}; do
    HASH=$(has_updates "$i") && {
        ftp_sync "$i";
        update_old_hash "$i" "$HASH";
    }
done;

exit 0;


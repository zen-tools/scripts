#!/usr/bin/env bash

# Initial vars
APP_ICON="dialog-information";
APP_NAME="FreeRDP GUI";
DOMAIN_NAME="Test";
CONNECTION_ADDRESS="127.0.0.1";
LOG_FILE="/tmp/FreeRDP.log"
HAS_STDOUT=0;

# Check script dependencies
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

# Show message
function error_message () {
    local MESSAGE="$@";

    echo "[$(LC_ALL=C date)] $MESSAGE" >> $LOG_FILE;

    (( $HAS_STDOUT > 0 )) && {
        echo -e "$MESSAGE" 1>&2;
    } || {
        notify-send -t 10000 -i $APP_ICON "$APP_NAME" "$MESSAGE" &> /dev/null
    }
}

# Get login and password
function get_user_input () {
    local USER_INPUT;
    (( $HAS_STDOUT > 0)) && {
        USER_INPUT=$(whiptail --backtitle "Авторизация на сервере" --inputbox "Логин:" 10 40 3>&1 1>&2 2>&3) || return 1;
        USER_INPUT="$USER_INPUT|$(whiptail --backtitle "Авторизация на сервере" --inputbox "Пароль:" 10 40 3>&1 1>&2 2>&3)" || return 1;
    } || {
        USER_INPUT=$(
            zenity  --forms \
                    --title="$APP_NAME" \
                    --text="Авторизация на сервере:" \
                    --add-entry="Логин:" \
                    --add-password="Пароль:" \
        ) || return 1;
    }
    echo $USER_INPUT;
}

# Check script dependencies
REQUIRED_APPS=();
test -t 1 && {
    HAS_STDOUT=1;
    REQUIRED_APPS+=(whiptail xfreerdp);
} || {
    REQUIRED_APPS+=(zenity xfreerdp notify-send);
}

NOT_FOUND=( $(require ${REQUIRED_APPS[@]}) ) || {
    error_message "Нерешенные зависимости: $(printf '%s ' ${NOT_FOUND[@]})";
    exit 1;
}

USER_INPUT=$(get_user_input) || {
    # The 'Cancel' button was pressed
    exit 0;
}

USER_LOGIN="${USER_INPUT%%|*}";
USER_PASSD="${USER_INPUT#*|}";

MSG=$(xfreerdp -f -d "$DOMAIN_NAME" -u "$USER_LOGIN" -p "$USER_PASSD" "$CONNECTION_ADDRESS" 2>&1) || {
    error_message $MSG;
    exit 2;
}

exit 0;


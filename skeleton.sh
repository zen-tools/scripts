#!/usr/bin/env bash

# Initial vars
APP_ICON="dialog-information";
APP_NAME="My Skeleton";

FILE_NAME=$(echo "$APP_NAME" | tr 'A-Z' 'a-z' | tr -d '[:space:]');
CONFIG="$HOME/.config/$FILE_NAME.conf";
LOCK_FILE="/tmp/$FILE_NAME.tmp";
PID="$(pgrep -F "$LOCK_FILE" 2> /dev/null)";
unset FILE_NAME;

# Read config
function save_config () {
    echo "TIMEOUT=$TIMEOUT" > "$CONFIG";
    echo >> "$CONFIG";
}

# Save config
function load_config () {
    TIMEOUT="$(awk -F'=' '/TIMEOUT/{print $2}' "$CONFIG" 2>/dev/null)";
    TIMEOUT=${TIMEOUT:-10000};
}

# Show message
function message () {
    notify-send -t "$TIMEOUT" -i "$APP_ICON" "$APP_NAME" "$@" &> /dev/null \
    || echo "$@" 1>&2;
}

# Check script dependencies
function require () {
    for bin in $@
    do
        if [[ -z $(which $bin 2> /dev/null) ]]
        then
            message "ERROR: $bin not found" 1>&2;
            exit 1;
        fi
    done
}

# Load config
load_config;

# Check to notify-send exist
test -n "$(which notify-send 2> /dev/null)" \
    || { message "WARNING: notify-send not found"; };

# Check dependencies
require awk;

# Exit if another process is run
test -z "$PID" \
    && { echo $$ > "$LOCK_FILE"; } \
    || { exit 1; };

# Create if not exist config directory
mkdir -p "${CONFIG%/*}";

# Check write access to config directory
test -w "${CONFIG%/*}" \
    || { message "ERROR: Cannot create config file"; exit 2; };

# Show message
message "Sample text\nConfig file: $CONFIG\nLock file: $LOCK_FILE";

# Save config
save_config;

# Clean up
rm "$LOCK_FILE";

exit 0;


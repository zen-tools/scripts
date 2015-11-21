#!/usr/bin/env bash
# Video Recording v 2.0
#
# http://linuxhub.ru/viewtopic.php?f=23&p=404
#
# Copyright (c) 2012-2013 by Poltavchenko Dmitriy <admin@linuxhub.ru>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.

APP_ICON="camera-video";
APP_NAME="Video Recording";
PROC_PRIORITY=19;
VIDEO_CAPTURE_BIN="avconv"; # or use "ffmpeg";
FILE="$HOME/$(date "+%F-%H-%M-%S").mkv";

############################### FUNCTION  LISTS ###############################
# Show message
function message () {
    notify-send -t 10000 -i $APP_ICON "$APP_NAME" "$@";
}

# Make and return the string of parameters for region capture
function parseWinInfo () {
    PARAMS="$@";
    ENCODER_OPT_TPL="XWxYH -i :0.0+XOFF,YOFF";
    VAL=("XOFF" "YOFF" "XW" "YH");

    for i in $PARAMS
    do
        TMP=$i;
        if [[ ($NUM -ge 2) && ($(( $TMP % 2 )) != 0) ]]
        then
            TMP=$(( $TMP + 1 ));
        fi
        ENCODER_OPT_TPL=$(echo $ENCODER_OPT_TPL | sed "s/${VAL[$NUM]}/$TMP/g");
        NUM=$(( $NUM + 1 ));
    done
    echo $ENCODER_OPT_TPL;
}

# Get window pos/height/width or exit
function getWinInfo () {
    PARAMS=$(xwininfo | egrep 'Absolute|Width|Height' | awk -F: '{print $2}');
    if [[ -z $PARAMS ]]
    then
        message "Cannot get windows properties";
        exit 2;
    fi
    echo $PARAMS;
}

# Check script dependencies
function require () {
    for i in $@
    do
        if [[ -z $(which $i) ]]
        then
            message "ERROR: $i not found" 1>&2 ;
            exit 1;
        fi
    done
}

# on SIGTERM
function terminated () {
    message "Recording terminated";
    kill -SIGTERM $PROC_ID;
    exit 0;
}
###############################################################################

################################## MAIN LOOP ##################################
unset PROC_ID;
trap terminated TERM;

require $VIDEO_CAPTURE_BIN notify-send xwininfo nice egrep awk sed date;

PARAMS=$(getWinInfo);
REGION=$(parseWinInfo $PARAMS);

nice -n $PROC_PRIORITY $VIDEO_CAPTURE_BIN -y -f alsa -i default -f x11grab   \
-framerate 24 -show_region 1 -video_size $REGION -threads 4 -q 1 -bt 8000000 \
-b 8500000 $FILE -v quiet & PROC_ID=$!;

wait;
###############################################################################

exit 0;


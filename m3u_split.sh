#!/bin/bash
set +H;
READY=1;
FILE_NAME=;
EXT="sh";
HEADER="#!/bin/bash";
EXTINF=;
SERVER=;
EOFILE="exit 0";
BIN="mplayer -fs";
cat iptv-full.m3u | while read line
do
    if [[ READY -eq 0 ]]
    then
        NEW_FILE="/tmp/${FILE_NAME}.$EXT";
        echo "Make file \"${NEW_FILE}\"";
        echo $HEADER >> "${NEW_FILE}";
        echo $EXTINF >> "${NEW_FILE}";
        echo $SERVER >> "${NEW_FILE}";
        echo $EOFILE >> "${NEW_FILE}";
        chmod +x "${NEW_FILE}";
        READY=1;
    fi

    case $line in
    "#EXTM3U") ;;
    \#EXTINF*)
        EXTINF="$line";
        FILE_NAME=$(
            echo $line \
                | awk -F, '{print $2}' \
                | sed 's/[^[:alnum:]^+ .-]//g'
            );
        ;;
    *)
        SERVER="$BIN $line";
        READY=0;
        ;;
    esac
done

exit 0;


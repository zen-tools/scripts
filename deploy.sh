#!/usr/bin/env bash

FTP_HOST="ftp.webserver.ua";
FTP_USER="username";
FTP_PASS="password";

SOURCE="$(dirname $0)/src/";
TARGET="/www/";

which lftp &> /dev/null || {
    echo "ERROR: lftp not found" 1>&2;
    exit 1;
}

test -r "$SOURCE" || {
    echo "ERROR: Source directory is not readble" 1>&2;
    exit 2;
}

lftp -u "$FTP_USER","$FTP_PASS" -e \
    "set ftp:passive-mode off; \
    mirror     \
    -x .svn    \
    -x .git    \
    -x cache   \
    -x sitemap \
    -v -n -R   \
    $SOURCE    \
    $TARGET;   \
    bye;"      \
    $FTP_HOST;

exit 0;


#!/usr/bin/env bash
## PHPBB VARIABLE CONFIG
# Login
LOGIN="User"
# Password
PASS="Secret"
# POST data for login
POST_DATA="username=$LOGIN&password=$PASS&login=%D0%92%D1%85%D0%BE%D0%B4"
# url to login page
LOGIN_URL="http://example.com/forum/ucp.php?mode=login"
# url to page to post messages
TARGET_URL="http://example.com/forum/viewforum.php?f=5"
# url to logout page
LOGOUT_URL="http://example.com/forum/ucp.php?mode=logout"
# path to temporaly cookies file
COOKIES_PATH="/tmp/cookies.txt"

## RSS VARIABLE CONFIG
# Path to file whith last update date
CFG_FILE="./rss.sav"
# Target url
RSS_URL="http://www.opennet.ru/opennews/opennews_all_noadv.rss"
# Page encoding
PAGE_ENC="koi8-r"
# Last update
LAST_UPDATE=""
# News values arrays
declare -a title
declare -a guid
declare -a description
# News date array
declare -a pubdate
# News items counter
step=-1
# Check operation by tag <item>
TRIGGER=""

## FUNCTION LIST
function warn() {
    echo "$@" 1>&2;
}

function read_sav() {
    if [[ -r $CFG_FILE ]]
    then
        read LAST_UPDATE < $CFG_FILE
    else
        warn "You dont have permission to read from file"
    fi
}

function write_sav() {
    if [[ -w $CFG_FILE ]]
    then
        echo "$@" > $CFG_FILE
    else
        warn "You dont have permission to write in file"
    fi
}

function parse_RSS() {
    # Parsing XML source page into arrays
    while read line
    do
        if [[ $(expr match "$line" "<item>") > 0 ]]
        then
            TRIGGER="item"
            let "step = $step + 1"
        elif [[ $(expr match "$line" "</item>") > 0 ]]
        then
            TRIGGER=""
        elif [[ $(expr match "$line" "^.*<link>.*") > 0 && $TRIGGER = "item" ]]
        then
            guid[$step]=`echo $line | sed 's|<.*>\(.*\)</.*>|\1|'`
        elif [[ $(expr match "$line" "^.*<title>.*") > 0 && $TRIGGER = "item" ]]
        then
            title[$step]=`echo $line | sed 's|<.*>\(.*\)</.*>|\1|' | html2text -nometa -ascii -width -1`
       #w3m -T text/html -dump | w3m -T text/html -dump
        elif [[ $(expr match "$line" "^.*<description>.*") > 0 && $TRIGGER = "item" ]]
        then
            description[$step]=`echo $line | sed 's|<.*>\(.*\)</.*>|\1|' | html2text -nometa -ascii -width -1`
       #w3m -T text/html -dump | w3m -T text/html -dump`
        elif [[ $(expr match "$line" "^.*<pubDate>.*") > 0 && $TRIGGER = "item" ]]
        then
            pubdate[$step]=`echo $line | sed 's|<.*>\(.*\)</.*>|\1|'`
            if [[ ${pubdate[$step]} = $LAST_UPDATE ]]
            then
                unset title[$step]
                unset description[$step]
                unset guid[$step]
                unset pubdate[$step]
                let "step = $step - 1"
                break
            fi
        fi
    done < <(wget $RSS_URL -q -O - | iconv -f $PAGE_ENC | sed 's|\(</[^>]*>\)|\1\n|g')
}

function phpbbnext_login {
    # Login and save cookies file
    wget --cookies=on --keep-session-cookies \
    --save-cookies=$COOKIES_PATH \
    --post-data $POST_DATA $LOGIN_URL -q -O - > /dev/null
}

function phpbbnext_post_message {
    # Prepare post data for message posting
    SUBJ=$1
    MESSAGE=$2
    POST_DATA=`
    wget --referer=$LOGIN_URL --cookies=on \
    --load-cookies=$COOKIES_PATH --keep-session-cookies \
    --save-cookies=$COOKIES_PATH $TARGET_URL -q -O - |
    egrep "lastclick|creation_time|form_token" |
    sed 's/^.*name="//g;s/" value="/=/g;s/" \/>$/\&/g' |
    tr -d '\n'`

    POST_DATA="poll_title=&poll_option_text=&poll_max_options=1&poll_length=0"$POST_DATA
    POST_DATA="post=%D0%9E%D1%82%D0%BF%D1%80%D0%B0%D0%B2%D0%B8%D1%82%D1%8C&"$POST_DATA
    POST_DATA="message=$MESSAGE&attach_sig=on&topic_type=0&topic_time_limit=0&"$POST_DATA
    POST_DATA="subject=$SUBJ&addbbcode40=0&addbbcode20=100&"$POST_DATA

    # 20 second sleep for antispam
    sleep 20s

    # Post message
    RESULTAT=`wget --referer=$TARGET_URL --cookies=on \
    --load-cookies=$COOKIES_PATH --keep-session-cookies \
    --save-cookies=$COOKIES_PATH --post-data "$POST_DATA" \
    $TARGET_URL -q -O - | grep "Сообщение было успешно отправлено."`

    # if message not posted
    if [[ -z $RESULTAT ]]
    then
        warn " \_> Message rejected"
   echo $RESULTAT
    fi
}

function phpbbnext_logout {
    # Logout and remove cookies file
    wget --referer=$TARGET_URL --cookies=on \
    --load-cookies=$COOKIES_PATH --keep-session-cookies \
    --save-cookies=$COOKIES_PATH --post-data "$POST_DATA" \
    $LOGOUT_URL -q -O - > /dev/null

    rm $COOKIES_PATH
}

## MAIN LOOP
# read last update date
if [[ -e $CFG_FILE ]]
then
    read_sav
else
    touch $CFG_FILE
fi
#parse RSS XML file
parse_RSS
# login into phpbb forum
phpbbnext_login
# Posting messages to forum
for i in $(seq $step -1 0)
do
    warn "Trying post news '${title[$i]}'"
    subj=`echo ${title[$i]} | uni2ascii -saJ`
    message=`echo ${description[$i]} [url=${guid[$i]}]Подробности[/url]. | uni2ascii -saJ`
    phpbbnext_post_message "$subj" "$message"
done
# logout from phpbb forum
phpbbnext_logout
# write last update date
if [[ -n ${pubdate[0]} ]]
then
    write_sav ${pubdate[0]}
else
    warn "No new news found"
fi

exit 0


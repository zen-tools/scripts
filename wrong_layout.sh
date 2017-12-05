#!/usr/bin/env bash

function ru_to_en() {
    echo "$@" | sed 'y1йцукенгшщзхъфывапролджэячсмитьбю.ЙЦУКЕНГШЩЗХЪ/ФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,"№;:?1qwertyuiop[]asdfghjkl;'\''zxcvbnm,./QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?@#$^&1';
}

function en_to_ru() {
    echo "$@" | sed 'y1qwertyuiop[]asdfghjkl;'\''zxcvbnm,./QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?@#$^&1йцукенгшщзхъфывапролджэячсмитьбю.ЙЦУКЕНГШЩЗХЪ/ФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,"№;:?1';
}

which wc &> /dev/null \
&& which xclip &> /dev/null \
&& which xdotool &> /dev/null || {
    echo "[ERROR] Check if wc/xclip/xdotool are installed." 1>&2;
    exit 1;
}

PREV_TEXT="$(cat /tmp/last_word.translit 2> /dev/null)";
TEXT="$(xclip -o)";
test -n "$TEXT" || exit 0;
test "$PREV_TEXT" == "$TEXT" && exit 0;
echo "$TEXT" > /tmp/last_word.translit;

if test "$(echo -n "$TEXT" | sed 's/[^a-zA-Z]//g' | wc -c)" -gt "$(echo -n "$TEXT" | sed 's/[a-zA-Z]//g' | wc -c)";
then
    NEW_TEXT="$(en_to_ru "$TEXT")";
else
    NEW_TEXT="$(ru_to_en "$TEXT")";
fi

echo -n "$NEW_TEXT" | xclip -i -selection c;
xdotool key ctrl+v &> /dev/null;

exit 0;

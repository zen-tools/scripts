#!/usr/bin/env bash

IN_FILE="$1";

test -n "$IN_FILE" || {
    echo "usage: $0 /path/to/file.txt";
    echo "or";
    echo "usage: $0 /path/to/file.txt > /path/to/output.html";
    exit 1;
}

test -r "$IN_FILE" || {
    echo "Cannot read file: $1" 1>&2;
    exit 2;
}

echo "<html><head></head><body><p>";

while read LINE; do
    # Parse URL: {http://url}
    LINE=$(echo $LINE | sed 's/{\(http[^{|}]\+\)}/<a href="\1">\1\<\/a>/g');

    # Parse URL: {example|http://url}
    LINE=$(echo $LINE | sed 's/{\([^{|}]\+\)|\(http[^}]\+\)}/<a href="\2">\1\<\/a>/g');

    # Parse Img: [Url]
    LINE=$(echo $LINE | sed 's/\[\(http[^[]\+\)\]/<img src="\1"\/>/g');

    # Parse Italic text: _example_
    LINE=$(echo $LINE | sed 's/_\([^_]\+\)_/<i>\1<\/i>/g');

    # Parse Bold text: *example*
    LINE=$(echo $LINE | sed 's/\*\([^*]\+\)\*/<b>\1<\/b>/g');

    echo "$LINE<br>";
done < <(cat "$IN_FILE");

echo "</p></body></html>";

exit 0;


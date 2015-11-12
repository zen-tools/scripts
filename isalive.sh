isalive () {
    HOST=${1:-'8.8.8.8'};
    while true
    do
        ping -c1 "$HOST" &> /dev/null && {
            notify-send -t 60000 -i network-wired "Есть коннект!" "$HOST доступен";
            break;
        } || {
            sleep 1m;
        }
    done
}

isalive "$1";

exit 0;


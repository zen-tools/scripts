#!/usr/bin/env bash
set -e;

scriptDependencies=(
    wc awk paste printf test
);

numProcessors="$(nproc)";
loadSeries=();
loadSeriesFlushAt=10;
alertAt=60;

function log_error() {
    echo "[$(date -u +"%d-%m-%Y %H:%M:%S")] [ERROR] $@" 1>&2;
}

function log_info() {
    echo "[$(date -u +"%d-%m-%Y %H:%M:%S")] [INFO] $@" 1>&2;
}

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

unmetDependencies=( $(require ${scriptDependencies[@]}) ) || {
    log_error "Unresolved dependencies: $(printf '%s ' ${unmetDependencies[@]})";
    exit 1;
}

lastTotalIdle=$(head -n1 /proc/stat | awk '{print $5}');
while true
do
    percent=0;
    TotalIdle=$(head -n1 /proc/stat | awk '{print $5}');

    test "$TotalIdle" -ge "$lastTotalIdle" && {
        diff=$(echo "scale=2; ($TotalIdle - $lastTotalIdle) / 100.0" | bc);
        percent=$(echo "scale=2; 100.0 - ($diff / $numProcessors * 100.0)" | bc);
    }

    lastTotalIdle=$TotalIdle;
    cpuLoad=${percent%.*};
    loadSeries+=($cpuLoad);

    test "${#loadSeries[@]}" -ge "$loadSeriesFlushAt" && {
        sumSeries=$(printf "%s\n" ${loadSeries[@]} | paste -s -d+ | bc);
        loadSeries=();
        avgLoad=$(echo $sumSeries / $loadSeriesFlushAt | bc);

        test "$avgLoad" -ge $alertAt && {
            log_info "High CPU load!!!";
        }
    }

    log_info $(printf "%03d %%\n" $cpuLoad);
    sleep 1;
done

#!/usr/bin/env bash

DATA=(
    "1 OpenNews: Каналу #rusunix 2 года."
    "3 OpenNews: Тестирование системы UNIX новостей"
    "5 OpenNews: Hurd живет!"
    "9 OpenNews: Обзор статей в журнале &quot;Открытые системы. СУБД&quot; N 11-12 за 1999 г."
    "11 OpenNews: Вышла новая версия программы KDevelop (1.2)."
    "13 OpenNews: Зашифрование swap в ядре OpenBSD"
);

let MAX_PROCS=$(nproc)+1

for ITEM in "${DATA[@]}"
do
    # Количество фоновых процессов
    JOB_PIDS=( $(jobs -p) );

    # Ожидаем завершение фоновой задачи,
    # если фоновых задач больше чем количество ядер + 1
    test "${#JOB_PIDS[@]}" -ge "$MAX_PROCS" && wait;

    NEWS_ID="${ITEM/ */}";
    LOCAL_NEWS_NAME="${ITEM#* }";
    REMOTE_NEWS_NAME=$(
        wget -UTest -q "http://www.opennet.ru/opennews/art.shtml?num=$NEWS_ID" -O - | awk -F'>|<' '/<title>/{print $3; exit;}' | iconv -f koi8-r
    ) && {
        test "$LOCAL_NEWS_NAME" = "$REMOTE_NEWS_NAME" && STATUS="OK" || STATUS="FAIL";
        echo "$NEWS_ID: '$LOCAL_NEWS_NAME' <=> '$REMOTE_NEWS_NAME' = $STATUS";
    } & # <== Код начиная с инициализации пемеренной 'REMOTE_NEWS_NAME' до этой строки будет выполняться в фоне
done;

wait;
exit 0;


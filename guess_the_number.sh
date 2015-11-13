#!/bin/bash

is_number () {
    SYM_COUNT=$(expr match "$1" "^[0-9]*$");
    test "$SYM_COUNT" -eq "0" && return 1;
    return 0;
}

game () {
    COUNT=0;

    while test "$COUNT" -le "$TRY_COUNT"
    do
        read -p"> " INPUT;

        is_number "$INPUT" || {
            echo "Я загадал число, а не слово";
            continue;
        }

        let COUNT+=1;

        test "$INPUT" -lt "$RND" && {
            echo "Слишком маленькое число, нужно больше!";
            continue;
        }

        test "$INPUT" -gt "$RND" && {
            echo "Число слишком большое!";
            continue;
        }

        echo "Поздравляю! Ты угадал с $COUNT-й попытки";
        break;
    done

}

MAX_NUMBER=100;
TRY_COUNT=8;
RND=$(( $RANDOM % $MAX_NUMBER ));

echo "Хочешь выиграть авторучку?";
echo "Тогда угадай, какое я задумал число от 0 до $MAX_NUMBER";
echo "У тебя $TRY_COUNT попыток :)";

while true
do
    game;

    read -p "Хочешь сыграть еще? (Yes/No) " QUERY;

    case $QUERY in
        [Yy][Ee][Ss] | [Yy])
            echo "Отлично! Я как раз задумал новое число!";
            RND=$(($RANDOM%$MAX_NUMBER));
        ;;
        [Nn][Oo] | [Nn])
            echo "Очень жаль! Мне будет скучно :(";
            break;
        ;;
        *)
            echo "Ты невменяем! Я с такими не играю!";
            break;
        ;;
    esac
done

exit 0;


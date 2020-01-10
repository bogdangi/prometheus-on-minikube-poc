#!/bin/bash

urlencode () {
        # urlencode <string>
        old_lc_collate=$LC_COLLATE
        LC_COLLATE=C

        local length="${#1}"
        for (( i = 0; i < length; i++ )); do
                local c="${1:i:1}"
                case $c in
                        [a-zA-Z0-9.~_-]) printf "$c" ;;
                        *) printf '%%%02X' "'$c" ;;
                esac
        done

        LC_COLLATE=$old_lc_collate
}

urldecode () {
        # urldecode <string>

        local url_encoded="${1//+/ }"
        printf '%b' "${url_encoded//%/\\x}"
}

retry () {
        local -r -i max_attempts="$1"; shift
        local -r cmd="$@"
        local -i attempt_num=1

        until $cmd
        do
                if (( attempt_num == max_attempts ))
                then
                        echo "Attempt $attempt_num failed and there are no more attempts left!"
                        return 1
                else
                        echo "Attempt $attempt_num failed! Trying again in $attempt_num seconds..."
                        sleep $(( attempt_num++ ))
                fi
        done
}


#!/usr/bin/env bash

tildify() {
    if [ -n "${HOME+defined}" ]; then
        echo "$1" | command sed "s@^$HOME@~@"
    else
        echo "$1"
        return 1
    fi
}

join() {
    local sep="$1" result="$2"
    shift; shift

    if [ -z "$result" ]; then
        return
    fi

    for item in "$@"; do
        result="$result$sep$item"
    done
    echo "$result"
}

contains() {
    local it="$1"
    shift

    local has_it=
    for item in "$@"; do
        if [ "$it" = "$item" ]; then
            has_it=yes
            break
        fi
    done
    test -n "$has_it"
}

#!/usr/bin/env bash

gitroot() {
    command git rev-parse --show-toplevel 2> /dev/null
}

tildify() {
    if [ -z "${HOME+defined}" ]; then
        echo "$1"
        return 1
    fi

    echo "$1" | command sed "s|^$HOME|~|"
}

join() {
    local sep="$1" result="$2"
    shift 2

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

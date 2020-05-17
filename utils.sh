#!/usr/bin/env bash

gitroot() {
    git rev-parse --show-toplevel 2> /dev/null
}

tildify() {
    if [ -z "${HOME+defined}" ]; then
        echo "$1"
        return 1
    fi

    echo "$1" | sed "s|^$HOME|~|"
}

strjoin() {
    local sep="$1" result="${2-}"
    shift 2

    if [ -z "$result" ]; then
        return
    fi

    local item
    for item in "$@"; do
        result="$result$sep$item"
    done
    echo "$result"
}

contains() {
    local it="$1"
    shift

    local item
    for item in "$@"; do
        if [ "$it" = "$item" ]; then
            return
        fi
    done
    return 1
}

unique() {
    local item coll=()
    for item in "$@"; do
        if ! contains "$item" "${coll[@]}"; then
            coll+=("$item")
        fi
    done
    echo "${coll[*]}"
}

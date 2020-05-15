#!/usr/bin/env bash

find_git_root() {
    local path
    path="$(command git rev-parse --absolute-git-dir 2> /dev/null)"
    if [ -z "$path" ]; then
       return 1
    fi
    echo "${path%\.git}"
}

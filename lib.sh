#!/usr/bin/env bash

readonly nixify_name=nixify
readonly nixify_version=0.2.1
readonly nixify_description="\
A little tool to init nix and direnv environment.\
"

show_usage() {
    echo "\
Usage: $nixify_name \
[-r|--rev REV [--sha256 SHA256]] \
[-n|--pname NAME] \
[-v|--version VERSION] \
[-p|--build-inputs [PKG...]] \
[-P|--native-build-inputs [PKG...]] \
[-s|--shell-build-inputs [PKG...]] \
[-h|--help] \
[-V]\
"
}

show_help() {
    show_usage
    echo "
$nixify_description

Options:
    -r, --rev REV                       pin nixpkgs to revision hash REV
        --sha256 SHA256                 sha256 checksum of the pinned nixpkgs (optional)
    -n, --pname NAME                    set package pname to NAME
    -v, --version VERSION               set package version to VERSION
    -p, --build-inputs [PKG...]         set packages in buildInputs
    -P, --native-build-inputs [PKG...]  set packages in nativeBuildInputs
    -s, --shell-build-inputs [PKG...]   set packages in buildInputs of shell.nix
    -h, --help                          show help
    -V                                  show program version\
"
}

show_version() {
    echo "$nixify_version"
}

# 96: bright cyan, 94: bright blue
nixify_color=96
toggle_nixify_color() {
    case "$nixify_color" in
        94) nixify_color=96;;
        96) nixify_color=94;;
        *) return 1;;
    esac
}

msg() {
    toggle_nixify_color
    echo -e "\e[${nixify_color}m$nixify_name:\e[0m $*" >&2
}

warn() {
    toggle_nixify_color
    echo -e "\e[${nixify_color}m$nixify_name:\e[0m \e[33m$*\e[0m" >&2
}

err() {
    toggle_nixify_color
    echo -e "\e[${nixify_color}m$nixify_name:\e[0m \e[31m$*\e[0m" >&2
    exit 1
}

prefetch_nixpkgs() {
    local rev="$1"

    nixpkgs_sha256_memo="$(command mktemp --suffix "$nixify_name")"

    __prefetch_cleanup() {
        command rm -f "$nixpkgs_sha256_memo"
        unset nixpkgs_sha256_memo
        unset -f __prefetch_cleanup
    }

    msg "prefetching nixpkgs rev $rev..."
    local url="https://github.com/NixOS/nixpkgs/archive/$rev.tar.gz"
    if ! command nix-prefetch-url --type sha256 --unpack "$url" \
       | command tee "$nixpkgs_sha256_memo" 1> /dev/null
    then
        warn "...failed"
        __prefetch_cleanup
        return 1
    fi
    nixpkgs_sha256="$(command cat "$nixpkgs_sha256_memo")"
    __prefetch_cleanup
    msg "...done! sha256 is $nixpkgs_sha256"
}

find_git_root() {
    local path
    path="$(command git rev-parse --absolute-git-dir 2> /dev/null)"
    if [ -z "$path" ]; then
       return 1
    fi
    echo "${path%\.git}"
}

abbr_home() {
    if [ -n "${HOME+defined}" ]; then
        echo "$1" | command sed "s@^$HOME@~@"
    else
        echo "$1"
        return 1
    fi
}

cd_project_root() {
    local project_root git_root

    if [ -n "${git_root:="$(find_git_root 2> /dev/null)"}" ]; then
        msg "guess git repo root $(abbr_home "$git_root") is the project root"
        project_root="$git_root"
    else
        msg "guess current directory is the project root"
        project_root="$PWD"
    fi

    if [ "$project_root" != "$PWD" ]; then
        msg "change working directory to $(abbr_home "$project_root")"
        cd "$project_root"
    fi
}

guess_pkg_pname() {
    command basename "$PWD"
}

add_nix_file() {
    local name="$1" template="$2"

    if [ -e "$name" ]; then
        local bk='~'
        while [ -e "$name$bk" ]; do
            bk="$bk$bk"
        done
        warn "$name exists; renamed to $name$bk"
        command mv "$name" "$name$bk"
    fi

    echo -n "$template" > "$name"
    msg "added $name"
}

add_gitignore() {
    if ! find_git_root > /dev/null 2>&1; then
        return
    fi

    local comment_line="# Nix and direnv stuff"
    local ignored_files=(.direnv result)

    if [ ! -e .gitignore ]; then
        echo "$comment_line" > .gitignore
        for file in "${ignored_files[@]}"; do
            echo "$file" >> .gitignore
        done
        msg "added .gitignore"
        return
    fi

    if ! command grep "$comment_line" .gitignore > /dev/null 2>&1; then
        echo >> .gitignore
        echo "$comment_line" >> .gitignore
        for file in "${ignored_files[@]}"; do
            echo "$file" >> .gitignore
        done
        msg "appended lines to .gitignore"
    fi
}

add_envrc() {
    if [ ! -e .envrc ]; then
        echo "use nix" > .envrc
        msg "added .envrc"
        return
    fi

    if ! command grep 'use nix' .envrc > /dev/null 2>&1; then
        echo "use nix" >> .envrc
        msg "appended 'use nix' to .envrc"
    fi
}

direnv_allow() {
    if ! command direnv allow; then
        warn "skipped executing 'direnv allow'"
    fi
}

pkgs_join() {
    local IFS="$1"
    shift
    echo "$*" | command sed 's/,/, /g'
}

contains() {
    local target="$1"
    shift

    local has_target
    for elem in "$@"; do
        if [ "$target" = "$elem" ]; then
            has_target=yes
            break
        fi
    done
    test -n "$has_target"
}

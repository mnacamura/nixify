#!/usr/bin/env bash

readonly nixify_name=nixify
readonly nixify_version=0.3.1
readonly nixify_description="\
A little tool to init nix and direnv environment.\
"

# shellcheck source=utils.sh
. utils.sh

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
[-V] \
[DEST]\
"
}

show_help() {
    show_usage
    echo "
$nixify_description

Arguments:
    DEST                                install files into DEST (optional)

Options:
    -r, --rev REV                       pin nixpkgs to revision hash REV
        --sha256 SHA256                 sha256 checksum of the pinned nixpkgs (optional)
    -n, --pname NAME                    set package pname to NAME
    -v, --version VERSION               set package version to VERSION
    -p, --build-inputs [PKG...]         set packages in buildInputs
    -P, --native-build-inputs [PKG...]  set packages in nativeBuildInputs
    -s, --shell-build-inputs [PKG...]   set packages in buildInputs of shell.nix

Flags:
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

parse_args() {
    local ignore_options=

    while [ "$#" -gt 0 ]; do
        if [ -z "$ignore_options" ]; then
            case "$1" in
                --)
                    ignore_options=yes
                    shift
                    ;;
                -r|--rev)
                    nixpkgs_rev="$2"
                    shift 2
                    ;;
                --sha256)
                    nixpkgs_sha256="$2"
                    shift 2
                    ;;
                -n|--pname)
                    pkg_pname="$2"
                    shift 2
                    ;;
                -v|--version)
                    pkg_version="$2"
                    shift 2
                    ;;
                -p|--build-inputs)
                    shift
                    while [ "$#" -gt 0 ]; do
                        case "$1" in
                            -*)
                                break
                                ;;
                            *)
                                pkg_build_inputs+=("$1")
                                shift
                                ;;
                        esac
                    done
                    ;;
                -P|--native-build-inputs)
                    shift
                    while [ "$#" -gt 0 ]; do
                        case "$1" in
                            -*)
                                break
                                ;;
                            *)
                                pkg_native_build_inputs+=("$1")
                                shift
                                ;;
                        esac
                    done
                    ;;
                -s|--shell-build-inputs)
                    shift
                    while [ "$#" -gt 0 ]; do
                        case "$1" in
                            -*)
                                break
                                ;;
                            *)
                                shell_build_inputs+=("$1")
                                shift
                                ;;
                        esac
                    done
                    ;;
                -h|--help)
                    show_help
                    exit
                    ;;
                -V)
                    show_version
                    exit
                    ;;
                --meow-meow)
                    is_meowing=yes
                    shift
                    ;;
                -*)
                    show_usage
                    exit 1
                    ;;
                *)
                    if [ -z "$project_root" ]; then
                        project_root="$1"
                        shift
                    else
                        show_usage
                        exit 1
                    fi
                    ;;
            esac
        else
            if [ -z "$project_root" ]; then
                project_root="$1"
                shift
            else
                show_usage
                exit 1
            fi
        fi
    done
}

prefetch_nixpkgs() {
    local rev="$1"

    nixpkgs_sha256_memo="$(mktemp --suffix "$nixify_name")"

    __prefetch_cleanup() {
        rm -f "$nixpkgs_sha256_memo"
        unset nixpkgs_sha256_memo
        unset -f __prefetch_cleanup
    }

    msg "prefetching nixpkgs rev $rev..."
    local url="https://github.com/NixOS/nixpkgs/archive/$rev.tar.gz"
    if ! nix-prefetch-url --type sha256 --unpack "$url" \
       | tee "$nixpkgs_sha256_memo" 1> /dev/null
    then
        warn "...failed"
        __prefetch_cleanup
        return 1
    fi
    nixpkgs_sha256="$(cat "$nixpkgs_sha256_memo")"
    __prefetch_cleanup
    msg "...done! sha256 is $nixpkgs_sha256"
}

cd_project_root() {
    local git_root

    if [ -n "$project_root" ]; then
        # project_root is explicitly specified, no guess
        true
    elif [ -n "${git_root:="$(gitroot)"}" ]; then
        msg "guess git repo root $(tildify "$git_root") is the project root"
        project_root="$git_root"
    else
        msg "guess current directory is the project root"
        project_root="$PWD"
    fi

    if [ "$project_root" != "$PWD" ]; then
        msg "change working directory to $(tildify "$project_root")"
        if ! cd "$project_root"; then
            err "cannot change directory to $project_root"
        fi
    fi
}

guess_pkg_pname() {
    basename "$PWD"
}

write_text() {
    local name="$1" contents="$2"

    if [ -e "$name" ]; then
        local bk='~'
        while [ -e "$name$bk" ]; do
            bk="$bk$bk"
        done
        warn "$name exists; renamed to $name$bk"
        mv "$name" "$name$bk"
    fi

    echo -n "$contents" > "$name"
    msg "added $name"
}

add_gitignore() {
    local git_root gitignore
    if [ -z "${git_root:=$(gitroot)}" ]; then
        return
    fi
    gitignore="$git_root/.gitignore"

    local comment_line ignored_entries
    comment_line="# Nix and direnv stuff"
    ignored_entries=(.direnv result)

    __append_lines_to() {
        local entry
        for entry in "${ignored_entries[@]}"; do
            echo "$entry" >> "$1"
        done
        unset -f __append_lines_to
    }

    if [ ! -e "$gitignore" ]; then
        echo "$comment_line" > "$gitignore"
        __append_lines_to "$gitignore"
        msg "added .gitignore"
        return
    fi

    if grep "$comment_line" "$gitignore" > /dev/null 2>&1; then
        return
    fi

    echo >> "$gitignore"
    echo "$comment_line" >> "$gitignore"
    __append_lines_to "$gitignore"
    msg "appended lines to .gitignore"
}

add_envrc() {
    if [ ! -e .envrc ]; then
        echo "use nix" > .envrc
        msg "added .envrc"
        return
    fi

    if grep '^use nix$' .envrc > /dev/null 2>&1; then
        return
    fi

    echo "use nix" >> .envrc
    msg "appended 'use nix' to .envrc"
}

direnv_allow() {
    if ! direnv allow; then
        warn "skipped executing 'direnv allow'"
    fi
}

#!/usr/bin/env bats

set -euo pipefail

# shellcheck source=lib.sh
. "$BATS_TEST_DIRNAME/../lib.sh" >&2

setup() {
    tmpd="$(mktemp -d --suffix "nixifytestgit")"
    pushd "$tmpd" \
    && git init
}

teardown() {
    rm -rf "$tmpd"
}

@test "ok if git root found" {
    gitroot
}

@test "fail if git root not found" {
    rm -rf .git
    ! gitroot
}

@test "no guess if dest is specified" {
    local project_root=x/y

    mkdir -p x/y/z
    run cd_project_root

    ! echo "$output" | grep 'guess current directory'
    ! echo "$output" | grep 'guess git repo root'
    echo "$output" | grep 'change working directory'
    ! echo "$output" | grep 'cannot change directory'
}

@test "guess git root is the project root" {
    local project_root=

    mkdir -p x/y/z
    pushd x/y/z
    run cd_project_root
    popd

    echo "$output" | grep 'guess git repo root'
    echo "$output" | grep 'change working directory'
}

@test "guess current directory is the project root if not in git repo" {
    local project_root=

    rm -rf .git
    mkdir -p x/y/z
    pushd x/y/z
    run cd_project_root
    popd

    echo "$output" | grep 'guess current directory'
    ! echo "$output" | grep 'change working directory'
}

@test "do not add .gitignore if not in git repo" {
    rm -rf .git
    run add_gitignore
    [ "$status" -eq 0 ]
    [ ! -e .gitignore ]
}

@test "add .gitignore in git repo" {
    mkdir x && pushd x
    run add_gitignore
    popd
    [ "$status" -eq 0 ]
    echo "$output" | grep "added .gitignore"
    cat .gitignore | grep .direnv
    cat .gitignore | grep result
}

@test "do not append lines to .gitignore if .gitignore contains the lines" {
    cat > .gitignore <<EOF
# Nix and direnv stuff
.direnv
result
EOF
    run add_gitignore
    [ "$status" -eq 0 ]
    ! echo "$output" | grep "appended lines to .gitignore"
    cat .gitignore | grep "# Nix and direnv stuff"
}

@test "append lines to .gitignore if .gitignore exists" {
    echo "pen pineapple" > .gitignore
    run add_gitignore
    [ "$status" -eq 0 ]
    echo "$output" | grep "appended lines to .gitignore"
    cat .gitignore | grep 'pen pineapple'
    cat .gitignore | grep .direnv
    cat .gitignore | grep result
}

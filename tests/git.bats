#!/usr/bin/env bats

# shellcheck source=lib.sh
. "$BATS_TEST_DIRNAME/../lib.sh" >&2

setup() {
    set -uo pipefail
    tmpd="$(mktemp -d --suffix "nixifytestgit")"
    pushd "$tmpd" \
    && git init || return 1
}

teardown() {
    rm -rf "$tmpd"
    set +uo pipefail
}

@test "ok if git root found" {
    run gitroot
    [ "$status" -eq 0 ]
}

@test "fail if git root not found" {
    rm -rf .git
    run gitroot
    [ ! "$status" -eq 0 ]
}

@test "no guess if dest is specified" {
    local project_root=x/y

    mkdir -p x/y/z
    run cd_project_root

    [ "$status" -eq 0 ]
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

    [ "$status" -eq 0 ]
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

    [ "$status" -eq 0 ]
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
    grep .direnv .gitignore
    grep result .gitignore
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
    grep "# Nix and direnv stuff" .gitignore
}

@test "append lines to .gitignore if .gitignore exists" {
    echo "pen pineapple" > .gitignore
    run add_gitignore
    [ "$status" -eq 0 ]
    echo "$output" | grep "appended lines to .gitignore"
    grep 'pen pineapple' .gitignore
    grep .direnv .gitignore
    grep result .gitignore
}

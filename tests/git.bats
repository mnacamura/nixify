#!/usr/bin/env bats

set -euo pipefail

# shellcheck source=git.sh
. "$BATS_TEST_DIRNAME/../git.sh" >&2

setup() {
    tmpd="$(command mktemp -d --suffix "nixifytestgit")"
    pushd "$tmpd" \
    && command git init
}

teardown() {
    popd \
    && command rm -rf "$tmpd"
}

@test "ok if git root found" {
    find_git_root
}

@test "fail if git root not found" {
    command rm -rf .git
    ! find_git_root
}

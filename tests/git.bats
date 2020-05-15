#!/usr/bin/env bats

# shellcheck source=git.sh
source "$BATS_TEST_DIRNAME/../git.sh" >&2

setup() {
    tmpd="$(command mktemp -d --suffix "${nixify_name}test")"
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

#!/usr/bin/env fish

set -g nixify_name nixify
set -g nixify_version 0.2
set -g nixify_description "\
A little tool to init nix and direnv environment\
"

set -g pkg_name "my-pkg"
set -g pkg_version "0.1"  # NOTE: $version is a read-only variable in fish
set -g rev
set -g sha256
set -g build_inputs
set -g native_build_inputs

function show_help
    echo "\
Usage: $nixify_name [-h|--help] [-V] [-r|--rev=REV] [--sha256=SHA256] [-n|--name=NAME] [-v|--version=VERSION] [-p|--build-inputs=PKGS] [-P|--native-build-inputs=PKGS]

$nixify_description

Options:
    -h, --help                        show help
    -V                                show program version
    -r, --rev=REV                     pin nixpkgs to revision hash REV
        --sha256=SHA256               sha256 checksum of the pinned nixpkgs (optional)\
    -n, --name=NAME                   set package name to NAME
    -v, --version=VERSION             set package version to VERSION
    -p, --build-inputs=PKGS           set packages in buildInputs (comma separated list)
    -P, --native-build-inputs=PKGS    set packages in nativeBuildInputs (comma separated list)
"
end

function show_version
    echo $nixify_version
end

function msg
    echo $nixify_name: $argv >&2
end

function warn
    echo $nixify_name: (set_color yellow)$argv(set_color normal) >&2
end

function err
    echo $nixify_name: (set_color red)$argv(set_color red) >&2
    exit 1
end


if not command -q nix-prefetch-url
    err "nix-prefetch-url not found; ensure nix is installed"
end

if not command -q basename
or not command -q cat
or not command -q mktemp
or not command -q sort
or not command -q tee
or not command -q uniq
    err "basename, cat, mktemp, sort, tee, and/or uniq not found; ensure coreutils installed"
end


function prefetch_nixpkgs -a rev
    set -g sha256_memo (command mktemp --suffix $nixify_name)
    function __prefetch_cleanup --on-event PF_CLEANUP
        rm -f $sha256_memo
        set -e sha256_memo
        functions -e __prefetch_cleanup
    end

    msg "prefetching nixpkgs rev $rev..."
    set -l url "https://github.com/NixOS/nixpkgs/archive/$rev.tar.gz"
    command nix-prefetch-url --type sha256 --unpack $url | \
       command tee $sha256_memo 1> /dev/null
    if test ! $status -eq 0
        warn "...failed"
        emit PF_CLEANUP
        return 1
    end
    set sha256 (command cat $sha256_memo)
    emit PF_CLEANUP
    msg "...done! sha256 is $sha256"
end

function find_git_root
    if not command -q git
        return 1
    end

    set -l path (command git rev-parse --absolute-git-dir 2> /dev/null)
    if test ! $status -eq 0
        return 1
    end
    string replace --regex '/\.git$' '' $path
end

function cd_project_root
    set -l project_root

    set -l git_root (find_git_root 2> /dev/null)
    if test $status -eq 0
        msg "guess git repo root $git_root is the project root"
        set project_root $git_root
    else
        msg "guess current directory is the project root"
        set project_root $PWD
    end

    if test $project_root != $PWD
        msg "change working directory to $project_root"
        cd $project_root
    end
end

function guess_pkg_name
    set pkg_name (command basename $PWD)
end

function edit
    if test -n "$EDITOR"
        eval $EDITOR $argv
    else
        warn "Please set EDITOR environment variable to edit nix files."
    end
end

function add_envrc
    if test ! -e .envrc
        echo "use nix" > .envrc
        msg "added .envrc"
    else if not string match 'use nix' < .envrc &> /dev/null
        echo "use nix" >> .envrc
        msg "appended 'use nix' to .envrc"
    end
end

function add_nix_file -a name template
    if test -e $name
        set -l bk '~'
        while test -e $name$bk
            set bk $bk$bk
        end
        warn "$name exists, renamed to $name$bk"
        mv $name $name$bk
    end

    echo -n $template > $name
    msg "added $name"
end

function add_gitignore
    if not find_git_root &> /dev/null
        return
    end

    set -l comment_line "# Nix and direnv stuff"
    set -l ignored_files $comment_line\n".direnv"\n"result"

    if test ! -e .gitignore
        echo $ignored_files > .gitignore
        msg "added .gitignore"
    else
        if not string match $comment_line < .gitignore &> /dev/null
            echo \n$ignored_files >> .gitignore
            msg "appended lines to .gitignore"
        end
    end
end

function direnv_allow
    if command -q direnv
        command direnv allow
    else
        warn "direnv not found; skip executing 'direnv allow'"
    end
end



set -l nixify_options
set -a nixify_options (fish_opt --short h --long help)
set -a nixify_options (fish_opt --short V)
set -a nixify_options (fish_opt --short r --long rev --required-val)
set -a nixify_options (fish_opt --short s --long sha256 --long-only --required-val)
set -a nixify_options (fish_opt --short n --long name --required-val)
set -a nixify_options (fish_opt --short v --long version --required-val)
set -a nixify_options (fish_opt --short p --long build-inputs --required-val)
set -a nixify_options (fish_opt --short P --long native-build-inputs --required-val)
argparse $nixify_options -- $argv

if set -q _flag_h
    show_help
    exit
end

if set -q _flag_V
    show_version
    exit
end

cd_project_root

if set -q _flag_n
    set pkg_name $_flag_n
else
    guess_pkg_name
end

if set -q _flag_v
    set pkg_version $_flag_v
end

if set -q _flag_p
    set build_inputs (string split ',' $_flag_p)
    set build_inputs (string trim $build_inputs)
end

if set -q _flag_P
    set native_build_inputs (string split ',' $_flag_P)
    set native_build_inputs (string trim $native_build_inputs)
end

set common_inputs (string join \n $build_inputs $native_build_inputs | \
   command sort | command uniq | string split \n)

set -l default_nix_header "\
{ pkgs ? import <nixpkgs> {} }:
"

set -l shell_nix_header "\
with import <nixpkgs> {};
"

if set -q _flag_r
    set rev $_flag_r

    if set -q _flag_sha256
        set sha256 $_flag_sha256
    else
        prefetch_nixpkgs $rev
    end

    if test ! $status -eq 0
        warn "don't pin nixpkgs"
    else
        set default_nix_header "\
let
  nixpkgs = fetchNixpkgs {
    rev = \"$rev\";
    sha256 = \"$sha256\";
  };

  fetchNixpkgs = { rev, sha256 }:
  builtins.fetchTarball {
    url = \"https://github.com/NixOS/nixpkgs/archive/\${rev}.tar.gz\";
    inherit sha256;
  };
in

{ pkgs ? import nixpkgs {} }:
"

        set shell_nix_header "\
let
  nixpkgs = fetchNixpkgs {
    rev = \"$rev\";
    sha256 = \"$sha256\";
  };

  fetchNixpkgs = { rev, sha256 }:
  builtins.fetchTarball {
    url = \"https://github.com/NixOS/nixpkgs/archive/\${rev}.tar.gz\";
    inherit sha256;
  };
in

with import nixpkgs {};
"
    end
end

set -l pkg_nix_template "\
{ "(string join ', ' stdenv $common_inputs)" }:

stdenv.mkDerivation rec {
  pname = \"$pkg_name\";
  version = \"$pkg_version\";

  src = ./.;

  nativeBuildInputs = ["(string join ' ' '' $native_build_inputs)" ];

  buildInputs = ["(string join ' ' '' $build_inputs)" ];
}
"

set -l default_nix_template "\
$default_nix_header
with pkgs;

callPackage ./pkg.nix {}
"

set -l shell_nix_template "\
$shell_nix_header
mkShell {
  inputsFrom = [ (callPackage ./pkg.nix {}) ];

  buildInputs = [ ];

  shellHook = ''
  '';
}
"

add_envrc
add_nix_file pkg.nix $pkg_nix_template
add_nix_file default.nix $default_nix_template
add_nix_file shell.nix $shell_nix_template
add_gitignore
direnv_allow

# vim: fdm=expr

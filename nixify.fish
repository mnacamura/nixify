#!/usr/bin/env fish

set -g program_name nixify
set -g program_version 0.0.1
set -g program_description "\
A little tool to init nix and direnv environemnt\
"

set -l program_options
set -a program_options (fish_opt --short h --long help)
set -a program_options (fish_opt --short V)
argparse $program_options -- $argv

function show_help
    echo "\
Usage: $program_name [-h|--help] [-V]

$program_description

Options:
    -h, --help               show help
    -V                       show program version\
"
end

function show_version
    echo $program_version
end

if set -q _flag_h
    show_help
    exit
end

if set -q _flag_V
    show_version
    exit
end

function msg
    echo $program_name: $argv >&2 
end

function warn
    echo $program_name: (set_color yellow)$argv(set_color normal) >&2 
end

function err
    echo $program_name: (set_color red)$argv(set_color red) >&2 
    exit 1
end

function find_git_root
    if not command -q git
        return 1
    end

    set -l path (command git rev-parse --absolute-git-dir 2> /dev/null)
    if test $status -eq 0
        string replace --regex '/\.git$' '' $path
    else
        return 1
    end
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

    msg "change working directory to $project_root"
    cd $project_root
end

function edit
    if test -n "$EDITOR"
        eval $EDITOR $argv
    else
        warn "Please set EDITOR environment variable to edit nix files."
    end
end

function direnv_allow
    if command -q direnv
        command direnv allow
    else
        warn "direnv not found; skip executing 'direnv allow'"
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
    msg "editing $name"
    if test ! -e $name
        echo -n $template > $name
    end
    edit $name
end

function add_gitignore
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

set -l pkg_nix_template "\
{ stdenv }:

stdenv.mkDerivation rec {
  pname = \"my-pkg\";
  version = \"0.0.1\";

  src = ./.;

  nativeBuildInputs = [ ];

  buildInputs = [ ];
}
"

set -l default_nix_template "\
{ pkgs ? import <nixpkgs> {} }:

with pkgs;

callPackage ./pkg.nix {}
"

set -l shell_nix_template "\
with import <nixpkgs> {};

mkShell {
  inputsFrom = [ (callPackage ./pkg.nix {}) ];

  buildInputs = [ ];

  shellHook = ''
  '';
}
"

cd_project_root
add_envrc
add_nix_file pkg.nix $pkg_nix_template
add_nix_file default.nix $default_nix_template
add_nix_file shell.nix $shell_nix_template
add_gitignore
direnv_allow

# vim: fdm=expr

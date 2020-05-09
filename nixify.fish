#!/usr/bin/env fish

set -g program_name nixify

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

function edit
    if test -n "$EDITOR"
        eval $EDITOR $argv
    else
        warn "Please set EDITOR environment variable to edit nix files."
    end
end

function direnv_allow
    if type -fq direnv
        command direnv allow
    else
        warn "direnv not found; skip executing 'direnv allow'"
    end
end

function add_envrc
    if test ! -e .envrc
        echo "use nix" > .envrc
        msg "added .envrc"
        direnv_allow
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
    set -l ignored_files "# Nix and direnv stuff"\n".direnv"\n"result"

    if test ! -e .gitignore
        echo $ignored_files > .gitignore
        msg "added .gitignore"
    else
        if not string match '# Nix and direnv stuff' < .gitignore &> /dev/null
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

add_envrc
add_nix_file pkg.nix $pkg_nix_template
add_nix_file default.nix $default_nix_template
add_nix_file shell.nix $shell_nix_template
add_gitignore

# vim: fdm=expr

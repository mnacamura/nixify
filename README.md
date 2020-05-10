# nixify

A little tool to init nix and direnv environment, inspired by some nixify precedents

## Installation

```
> git clone https://github.com/mnacamura/nixify.git $SOMEWHERE
> ln -s $SOMEWHERE/nixify-overlay.nix ~/.config/nixpkgs/overlays/ 
> nix-env -f '<nixpkgs>' -iA nixify           # for the latest release, or
> nix-env -f '<nixpkgs>' -iA nixify-unstable  # for the latest unstable version
```

## Usage

```
> nixify --help
Usage: nixify [-h|--help] [-V] [-r|--rev=REV] [--sha256=SHA256] [-n|--name=NAME] [-v|--version=VERSION] [-p|--build-inputs=PKGS]

A little tool to init nix and direnv environment

Options:
    -h, --help               show help
    -V                       show program version
    -r, --rev=REV            pin nixpkgs to revision hash REV
        --sha256=SHA256      sha256 checksum of the pinned nixpkgs (optional)
    -n, --name=NAME          set package name to NAME
    -v, --version=VERSION    set package version to VERSION
    -p, --build-inputs=PKGS  set packages in buildInputs (comma separated list)
```

## Example 

```
> mkdir -p urrepo/subdir
> cd urrepo/
> git init
Initialized empty Git repository in /home/you/urrepo/.git/
> touch default.nix
> cd subdir/
> nixify --rev b1f802994
nixify: guess git repo root /home/you/urrepo is the project root
nixify: change working directory to /home/you/urrepo
nixify: prefetching nixpkgs rev b1f802994...
unpacking...
[18.3 MiB DL]
path is '/nix/store/h1xdkwbqk1pi98sq73gpmd4dfzpm1jsm-b1f802994.tar.gz'
nixify: ...done! sha256 is 1bwq805drajzga63kbs18n49dxa6ln48n5n7f0a2m91378m1b71x
nixify: added .envrc
nixify: added pkg.nix
nixify: default.nix exists; renamed to default.nix~
nixify: added default.nix
nixify: added shell.nix
nixify: added .gitignore
direnv: loading ~/urrepo/.envrc
direnv: using nix
direnv: renewed cache and derivation link
direnv: export +AR +AS +CC +CONFIG_SHELL +CXX +HOST_PATH +IN_NIX_SHELL +LD +NIX_BINTOOLS +NIX_BINTOOLS_WRAPPER_x86_64_unknown_linux_gnu_TARGET_HOST +NIX_BUILD_CORES +NIX_BUILD_TOP +NIX_CC +NIX_CC_WRAPPER_x86_64_unknown_linux_gnu_TARGET_HOST +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_INDENT_MAKE +NIX_LDFLAGS +NIX_STORE +NM +OBJCOPY +OBJDUMP +RANLIB +READELF +SIZE +SOURCE_DATE_EPOCH +STRINGS +STRIP +TEMP +TEMPDIR +TMP +TMPDIR +__ETC_PROFILE_SOURCED +buildInputs +builder +configureFlags +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +name +nativeBuildInputs +nobuildPhase +out +outputs +patches +phases +propagatedBuildInputs +propagatedNativeBuildInputs +shell +shellHook +stdenv +strictDeps +system ~PATH
> 
```

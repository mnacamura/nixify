# Change Log

## TODO

- Add shell completions (fish, bash, zsh)
- Add option to fill `buildInputs` in `shell.nix`
- Enable to use custom templates?
- Add tests (using `fishtape`?)
- Enable to specify the project directory
- Revert to initial state after aborting:
    1. First, install files to a temporal directory.
    2. If everything is OK, install the files in the temporal directory to the
       project directory.
    3. Otherwise, remove the temporal directory and exit.

## Unstable version

### Changed

- Long option name `--name` is now `--pname` for consistency

## [0.2.1](https://github.com/mnacamura/nixify/tree/0.2.1) (2020-05-10)

### Fixed

- Stop the program after command-line argument parsing failed

## [0.2](https://github.com/mnacamura/nixify/tree/0.2) (2020-05-10)

### Added

- Options `-n|--name` and `-v|--version` for inserting `pname` and
  `version` to pkg.nix
- Guess `pname` from the project root name if flag `-n` is not given
- Option `-p|--build-inputs` for inserting packages to `buildInputs`
- Option `-P|--native-build-inputs` for inserting packages to
  `nativeBuildInputs`

## [0.1](https://github.com/mnacamura/nixify/tree/0.1) (2020-05-10)

### Added

- Option `-h|--help` showing help message
- Option `-V` showing program version
- Option `-r|--rev` pinning nixpkgs revision
- Option `--sha256` using the given sha256 checksum for the pinned nixpkgs

# Change Log

## TODO

- Add integration tests
- Add shell completions (fish, bash, zsh)
- Enable to use custom templates?
- Revert to initial state after aborting:
    1. First, install files to a temporal directory.
    2. If everything is OK, install the files in the temporal directory to the
       project directory.
    3. Otherwise, remove the temporal directory and exit.

## Unstable version

### Fixed

- Program stops by an error with message `$2: unbound variable`

### Added

- Ability to specify installation destination

## [0.3.1](https://github.com/mnacamura/nixify/tree/0.3.1) (2020-05-16) **[BROKEN]**

### Fixed

- Spacing after comma in `pkg.nix`'s header

## [0.3](https://github.com/mnacamura/nixify/tree/0.3) (2020-05-16) **[BROKEN]**

### Changed

- Long option name `--name` is now `--pname` for consistency
- `-p|--build-inputs` and `-P|--native-build-inputs` are now given by space
  separated list
- Options do not accept `--option=value` form

### Added

- Colorful message prefix (`nixify: ...`)
- Option `-s|--shell-build-inputs` to set `buildInputs` in `shell.nix`

### Internal

- Rewritten in bash
- Added unit tests

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

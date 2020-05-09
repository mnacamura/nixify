# Change Log

## TODO

- Add options `-n|--name` and `-v|--version` for inserting `pname` and
  `version` to pkg.nix
- Add option `-p|--build-inputs` for inserting packages to `buildInputs`.
- Add option `-P|--native-build-inputs` for inserting packages to
  `nativeBuildInputs`.

## Unstable version

### Added

- Guess `pname` from the project root name

## [0.1](https://github.com/mnacamura/nixify/tree/0.1) (2020-05-10)

### Added

- Option `-h|--help` showing help message
- Option `-V` showing program version
- Option `-r|--rev` pinning nixpkgs revision
- Option `--sha256` using the given sha256 checksum for the pinned nixpkgs
{ stdenv, coreutils, gnugrep, nix, bats, gitMinimal, makeWrapper }:

let
  inherit (stdenv.lib) makeBinPath;
in

stdenv.mkDerivation rec {
  pname = "nixify";
  version = "unstable";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ coreutils gnugrep nix ];

  doCheck = true;

  checkInputs = [ bats gitMinimal ];

  installFlags = [ "PREFIX=$(out)" ];

  preFixup = ''
    wrapProgram $out/bin/nixify --prefix PATH : "${makeBinPath buildInputs}"
  '';

  meta = with stdenv.lib; {
    description = "A little tool to init nix and direnv environment";
    homepage = "https://github.com/mnacamura/nixify/";
    license = licenses.mit;
    maintainers = with maintainers; [ mnacamura ];
    platforms = platforms.unix;
  };
}

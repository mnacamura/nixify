{ stdenv, fish, coreutils, makeWrapper }:

let
  inherit (stdenv.lib) makeBinPath;
in

stdenv.mkDerivation rec {
  pname = "nixify";
  version = "unstable";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ fish coreutils ];

  dontConfigure = true;
  dontBuild = true;

  installFlags = [ "DEST=$(out)" "PREFIX=" ];

  preFixup = ''
    wrapProgram $out/bin/nixify --prefix PATH : "${makeBinPath [ coreutils ]}"
  '';

  meta = with stdenv.lib; {
    description = "A little tool to init nix and direnv environment";
    homepage = "https://github.com/mnacamura/nixify/";
    license = licenses.mit;
    maintainers = with maintainers; [ mnacamura ];
    platforms = platforms.all;
  };
}

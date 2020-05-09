{ stdenvNoCC, fish, coreutils, makeWrapper }:

let
  inherit (stdenvNoCC.lib) makeBinPath;
in

stdenvNoCC.mkDerivation rec {
  pname = "nixify";
  version = "unstable";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ fish coreutils ];

  buildCommand = ''
    install -D $src/nixify.fish $out/bin/nixify
    wrapProgram $out/bin/nixify --prefix PATH : "${makeBinPath buildInputs}"
  '';

  meta = with stdenvNoCC.lib; {
    description = "A little tool to init nix and direnv environment";
    homepage = "https://github.com/mnacamura/nixify/";
    license = licenses.mit;
    maintainers = with maintainers; [ mnacamura ];
    platforms = platforms.all;
  };
}

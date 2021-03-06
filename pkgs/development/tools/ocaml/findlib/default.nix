{stdenv, fetchurl, m4, ncurses, ocaml, writeText}:

stdenv.mkDerivation rec {
  name = "ocaml-findlib-${version}";
  version = "1.7.1";

  src = fetchurl {
    url = "http://download.camlcity.org/download/findlib-${version}.tar.gz";
    sha256 = "1vsys5gpahi36nxv5yx29zhwn8b2d7sqqswza05vxy5bx5wrljsx";
  };

  buildInputs = [m4 ncurses ocaml];

  patches = [ ./ldconf.patch ./install_topfind.patch ];

  dontAddPrefix=true;

  preConfigure=''
    configureFlagsArray=(
      -bindir $out/bin
      -mandir $out/share/man
      -sitelib $out/lib/ocaml/${ocaml.version}/site-lib
      -config $out/etc/findlib.conf
    )
  '';

  buildPhase = ''
    make all
    make opt
  '';

  setupHook = writeText "setupHook.sh" ''
    addOCamlPath () {
        if test -d "''$1/lib/ocaml/${ocaml.version}/site-lib"; then
            export OCAMLPATH="''${OCAMLPATH}''${OCAMLPATH:+:}''$1/lib/ocaml/${ocaml.version}/site-lib/"
        fi
        export OCAMLFIND_DESTDIR="''$out/lib/ocaml/${ocaml.version}/site-lib/"
        if test -n "$createFindlibDestdir"; then
          mkdir -p $OCAMLFIND_DESTDIR
        fi
    }

    envHooks+=(addOCamlPath)
  '';

  meta = {
    homepage = http://projects.camlcity.org/projects/findlib.html;
    description = "O'Caml library manager";
    license = stdenv.lib.licenses.mit;
    platforms = ocaml.meta.platforms or [];
    maintainers = [
      stdenv.lib.maintainers.z77z
      stdenv.lib.maintainers.vbmithr
    ];
  };
}



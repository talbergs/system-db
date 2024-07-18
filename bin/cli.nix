{
  pkgs,
  nixpkgs,
  name,
}:
pkgs.writeShellApplication {
  inherit name;
  text = ''
    set +u
    if [ -z "$1" ];then
        echo " choose port number \$1"
        echo " choose dbname (optional) \$2"
        exit 1
    fi

    port="$1"
    dbname="$2"
    if [ -z "$dbname" ];then
      dbname=postgres
    fi

    extra="$(echo "$*" | sed 's/.*-- //p' -n)"
    cmd="psql --host=0.0.0.0 --port=$port -U$(whoami) --dbname=$dbname $extra"

    if [ -t 0 ]; then
      echo running interactivelly
    else
      cmd="cat /dev/stdin | $cmd"
    fi

    nixenv="/tmp/running-$(basename "$0").nix"
    cat >"$nixenv" <<EOF
    { ... }:
    let
        pkgs = import <nixpkgs> {};
    in
    pkgs.mkShell {
        packages = with pkgs; [ less postgresql ];
        shellHook = '''
        eval "$cmd"
        exit
        ''';
      }
    EOF

    ${pkgs.nix}/bin/nix-shell \
      --pure \
      -I nixpkgs="${nixpkgs}" \
      "$nixenv"
  '';
}

{
  pkgs,
  nixpkgs,
  name,
}:
pkgs.writeShellApplication {
  inherit name;
  text = ''
    set +x
    set +u
    if [ -z "$3" ];then
        echo " choose port number \$1"
        echo " choose dbname \$2"
        echo " choose table name \$3"
        exit 1
    fi

    port="$1"
    dbname="$2"
    table="$3"
    if [ -z "$dbname" ];then
      dbname=postgres
    fi

    cmd="pg_dump --host=0.0.0.0 --port=$port -U$(whoami) --table=$table --dbname=$dbname --data-only --column-inserts"

    nixenv="/tmp/running-$(basename "$0").nix"
    cat >"$nixenv" <<EOF
    { ... }:
    let
        pkgs = import <nixpkgs> {};
    in
    pkgs.mkShell {
        packages = with pkgs; [ less postgresql];
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

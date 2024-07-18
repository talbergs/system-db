{
  pkgs,
  nixpkgs,
  name,
}:
pkgs.writeShellApplication {
  inherit name;
  text = ''
    set +u
    if [ -z "$2" ];then
        echo " choose port number \$1"
        echo " choose cluster data dir (PGDATA) \$2"
        exit 1
    fi

    port="$1"
    pgdata="$2"

    ${pkgs.nix}/bin/nix-shell \
      --run fg_postgres \
      -I nixpkgs="${nixpkgs}" \
      --argstr port "$port" \
      --argstr pgdata "$pgdata" \
      "${../postgres.nix}"
  '';
  runtimeInputs = [ ];
}

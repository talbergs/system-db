{ pkgs, name }:
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    git
    perl
    automake
    autoconf
    busybox
    gcc
    gnumake
  ];
  text = ''
    set +u
    set +x
    src="$1"
    dst="$2"
    if [ -z "$dst" ];then
        echo " choose source dir \$1"
        echo " choose result dir \$2"
        exit 1
    fi

    if [ ! -e "$src/bootstrap.sh" ];then
        echo " expected $src/bootstrap.sh"
        echo " \$1 has to be Zabbix source dir"
        exit 1
    fi

    tmp=/tmp/builder-$(basename "$0")
    sha=$(cd "$src" && git rev-parse HEAD)

    if [[ -d "$tmp" ]];then
        rm -rf "$tmp"
    fi
    mkdir -p "$tmp"

    cp -r "$src/src" "$tmp/src"
    cp -r "$src/database" "$tmp/database"
    cp -r "$src/include" "$tmp"
    cp -r "$src/man" "$tmp"
    cp -r "$src/misc" "$tmp"
    cp -r "$src/m4" "$tmp"
    cp -r "$src/create" "$tmp"
    cp -r "$src/conf" "$tmp"
    cp -r "$src/templates" "$tmp"

    cp "$src/configure.ac" "$tmp"
    cp "$src/AUTHORS" "$tmp"
    cp "$src/Makefile.am" "$tmp"
    cp "$src/ChangeLog" "$tmp"
    cp "$src/NEWS" "$tmp"
    cp "$src/README" "$tmp"
    cp "$src/bootstrap.sh" "$tmp"

    cd "$tmp"
    aclocal -I m4
    autoconf
    autoheader
    automake -a
    automake

    ./configure --with-mysql --with-postgresql

    make dbschema

    cd -

    if [[ -d "$dst" ]];then
        rm -rf "$dst"
    fi
    mkdir -p "$dst"

    cat \
        "$tmp/database/postgresql/schema.sql" \
        "$tmp/database/postgresql/images.sql" \
        "$tmp/database/postgresql/data.sql" \
    > "$dst/postgresql.sql"

    cat \
        "$tmp/database/mysql/schema.sql" \
        "$tmp/database/mysql/images.sql" \
        "$tmp/database/mysql/data.sql" \
    > "$dst/mysql.sql"

    echo "$sha" > "$dst/build_revision"
  '';
}

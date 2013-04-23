#!/bin/bash

function randpass() {
  [ "$2" == "0" ] && CHAR="[:alnum:]" || CHAR="[:graph:]"
    cat /dev/urandom | tr -cd "$CHAR" | head -c ${1:-32}
    echo
}

PASSWORD=`randpass 12 0`

if [ -f /root/.pg_service.conf ]; then
  echo "PASSWORD ALREADY SET HUMAN!!!"
  exit 1
fi

echo "ALTER USER postgres WITH PASSWORD '${PASSWORD}';" | psql -U postgres 2>&1 >> /dev/null

echo -e "[postgres]\ndbname=postgres\nuser=postgres\npassword=${PASSWORD}" > /root/.pg_service.conf


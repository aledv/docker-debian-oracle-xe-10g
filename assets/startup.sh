#!/bin/bash
LISTENER_ORA=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/network/admin/listener.ora
TNSNAMES_ORA=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/network/admin/tnsnames.ora

cp "${LISTENER_ORA}.tmpl" "$LISTENER_ORA" &&
sed -i "s/%hostname%/$HOSTNAME/g" "${LISTENER_ORA}" &&
sed -i "s/%port%/1521/g" "${LISTENER_ORA}" &&
cp "${TNSNAMES_ORA}.tmpl" "$TNSNAMES_ORA" &&
sed -i "s/%hostname%/$HOSTNAME/g" "${TNSNAMES_ORA}" &&
sed -i "s/%port%/1521/g" "${TNSNAMES_ORA}" &&

service oracle-xe start

export ORACLE_HOME=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=XE

if [ "$ORACLE_ALLOW_REMOTE" = true ]; then
  echo "alter system disable restricted session;" | sqlplus -s SYSTEM/oracle
fi

for f in /docker-entrypoint-initdb.d/*; do
  case "$f" in
    *.sh)     echo "$0: running $f"; . "$f" ;;
    *.sql)    echo "$0: running $f"; echo "exit" | /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/bin/sqlplus "SYS/oracle" AS SYSDBA @"$f"; echo ;;
    *)        echo "$0: ignoring $f" ;;
  esac
  echo
done

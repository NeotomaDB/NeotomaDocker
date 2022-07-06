#!/bin/bash
# Restore Neotoma from a database snapshot.
# by: Simon Goring

DOC_REQUEST=70

if [ "$1" = "-h"  -o "$1" = "--help" ]     # Request help.
then
  echo; echo "Usage: $0 [dump-file-path]"; echo
  sed --silent -e '/DOCUMENTATIONXX$/,/^DOCUMENTATIONXX$/p' "$0" |
  sed -e '/DOCUMENTATIONXX$/d'; exit $DOC_REQUEST; fi

#mkdir dbout
#wget https://www.neotomadb.org/uploads/snapshots/neotoma_ndb_only_2022-05-17.tar --no-check-certificate
#tar -xf neotoma_ndb_only_latest.tar -C ./dbout
#gunzip ./dbout/neotoma_ndb_latest.sql.gz
#dropdb -U postgres neotoma
createdb -U postgres neotoma
psql -U postgres -d neotoma -c "CREATE EXTENSION postgis; CREATE EXTENSION pg_trgm;"
psql -U postgres -d neotoma -f /dbruns/dbout/neotoma_ndb_latest.sql

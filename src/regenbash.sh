#!/bin/bash
# Restore Neotoma from a database snapshot.
# by: Simon Goring

DOC_REQUEST=70

if [ "$1" = "-h"  -o "$1" = "--help" ]     # Request help.
then
  echo; echo "Usage: $0 [dump-file-path]"; echo
  sed --silent -e '/DOCUMENTATIONXX$/,/^DOCUMENTATIONXX$/p' "$0" |
  sed -e '/DOCUMENTATIONXX$/d'; exit $DOC_REQUEST; fi


: <<DOCUMENTATIONXX
Restore the Neotoma Paleoecology Database Snapshot Locally
---------------------------------------------------------------
The commandline parameter provides the path to the `.dump` file that
is used to restore the Neotoma snapshot to a local database called
`neotoma`. It should be noted that this script runs under the users
profile. There are cases where individuals have set up PostgreSQL
to run under a different user's account, for example, `postgres`.
In this case we would run

sudo -u postgres bash regenbash.sh path-to-file.dump

DOCUMENTATIONXX

mkdir dbout
wget https://www.neotomadb.org/uploads/snapshots/neotoma_ndb_only_2022-05-17.tar --no-check-certificate
tar -xf neotoma_ndb_only_latest.tar -C ./dbout
gunzip ./dbout/neotoma_ndb_latest.sql.gz
dropdb -h localhost -U postgres neotoma
createdb  -h localhost -U postgres neotoma
psql -h localhost -U postgres -d neotoma -c "CREATE EXTENSION postgis; CREATE EXTENSION pg_trgm;"
psql -h localhost -U postgres -d neotoma -f ./dbout/neotoma_ndb_on 

createdb  -h localhost -U postgres epd
psql -h localhost -U postgres -d epd -c "CREATE EXTENSION postgis; CREATE EXTENSION pg_trgm;"
psql -h localhost -U postgres -d epd -c "CREATE SCHEMA ndb;"

pg_restore --no-privileges \
 --clean \
           --no-owner \
           --format=c \
           -h localhost \
           -U postgres \
           -d epd \
           ./dbout/db_epd.dump
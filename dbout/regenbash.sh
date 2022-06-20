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
The commandline parameter provides the path to the "dump" file (.sql) that
is used to restore the Neotoma snapshot to a local database called
"neotoma". It should be noted that this script runs under the users
profile. There are cases where individuals have set up PostgreSQL
to run under a different user's account, for example, "postgres".
In this case we would run

sudo -u postgres bash regenbash.sh path-to-file.sql

DOCUMENTATIONXX

dropdb neotoma
createdb neotoma
psql -d neotoma -c "CREATE EXTENSION postgis;"
psql -d neotoma -c "CREATE EXTENSION pg_trgm;"
psql -d neotoma -f $1

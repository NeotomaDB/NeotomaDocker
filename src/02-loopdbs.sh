psql -U postgres -d neotoma -n -t -R "," -c "SELECT databaseid, LOWER(databasename) FROM ndb.constituentdatabases;" -o ./dbruns/dbout/dbs.txt
today=$(date '+%Y-%m-%d')
cat dbruns/dbout/dbs.txt | sed 's/ *//g' | sed 's/[A-Z]*/\L&/g' > dbruns/dbout/dbb.txt

psql -U postgres -f dropTemp.sql > dbruns/dbout/sqllog.log

while read p; do
  IFS='|' read -a dbnames <<< $p
  lowercase=${dbnames[1],,}
  filename="constdb_${lowercase}_${today}.sql"
  echo ${filename}
  createdb  -U postgres temp
  psql -U postgres -d temp -c "CREATE EXTENSION postgis; CREATE EXTENSION pg_trgm;"
  psql -U postgres -d temp -f /dbruns/dbout/neotoma_ndb_latest.sql  > dbruns/dbout/sqllog.log
  echo Clean and dump.
  psql -U postgres -d temp -v dbid=${dbnames[0]} -f cleanToDB.sql
  pg_dump -U postgres  -O -n ndb -Fc temp > /dbruns/dbout/${filename}
  echo Drop the temporary database.
  psql -U postgres -f dropTemp.sql > dbruns/dbout/sqllog.log
done <dbb.txt

rm dbb.txt
rm dbs.txt

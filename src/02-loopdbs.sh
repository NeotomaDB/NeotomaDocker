psql -U postgres -d neotoma -n -t -R "," -c "SELECT databaseid, LOWER(databasename) FROM ndb.constituentdatabases;" --output=out/dbs.txt
today=$(date '+%Y-%m-%d')
cat out/dbs.txt | sed 's/ *//g' | sed 's/[A-Z]*/\L&/g' >out/dbb.txt

#psql -U postgres -f dropTemp.sql > out/sqllog.log

while read p; do
  IFS='|' read -a dbnames <<< $p
  lowercase=${dbnames[1],,}
  filename="constdb_${lowercase}_${today}.sql"
  echo ${filename}
  createdb  -U postgres temp
  psql -U postgres -d temp -c "CREATE EXTENSION postgis; CREATE EXTENSION pg_trgm;"
  psql -U postgres -d temp -f /dbruns/dbout/neotoma_ndb_latest.sql  > out/sqllog.log
  echo Clean and dump.
  psql -U postgres -d temp -v dbid=${dbnames[0]} -f sql/cleanToDB.sql
  pg_dump -U postgres  -O -n ndb -Fc temp > out/${filename}
  echo Drop the temporary database.
  psql -U postgres -f sql/dropTemp.sql > out/sqllog.log
done < out/dbb.txt

rm out/dbb.txt
rm out/dbs.txt

export PGPASSWORD=postgres
mkdir dbout
wget https://neotomadb.org/uploads/snapshots/neotoma_ndb_latest.tar --no-check-certificate
tar -xf neotoma_ndb_latest.tar -C ./dbout
gunzip ./dbout/neotoma_ndb_latest.sql.gz
createdb -h localhost -U postgres neotoma
psql -d neotoma -U postgres -h localhost -c "CREATE EXTENSION postgis;"
psql -d neotoma -U postgres -h localhost -c "CREATE EXTENSION pg_trgm;"
psql -h localhost -U postgres -d neotoma -f ./dbout/neotoma_ndb_latest.sql

psql -h localhost -U postgres -d neotoma -n -t -R "," -c "SELECT databaseid, LOWER(databasename) FROM ndb.constituentdatabases;" -o ./dbs.txt
today=$(date '+%Y-%m-%d')
cat dbs.txt | sed 's/ *//g' | sed 's/[A-Z]*/\L&/g' > dbb.txt

psql  -h localhost -U postgres -f dropTemp.sql > sqllog.log

while read p; do
  IFS='|' read -a dbnames <<< $p
  lowercase=${dbnames[1],,}
  filename="constdb_${lowercase}_${today}.sql"
  echo ${filename}
  createdb -h localhost -U postgres temp
  psql -h localhost -U postgres -d temp -c "CREATE EXTENSION postgis; CREATE EXTENSION pg_trgm;"
  psql -h localhost -U postgres -d temp -f ./dbout/neotoma_ndb_latest.sql  > sqllog.log
  echo Clean and dump.
  psql -h localhost -U postgres -d temp -v dbid=${dbnames[0]} -f cleanToDB.sql
  pg_dump -U postgres -h localhost -O -n ndb -Fc temp > ./dbout/${filename}
  echo Drop the temporary database.
  psql -h localhost -U postgres -f dropTemp.sql > sqllog.log
done <dbb.txt

rm dbb.txt
rm dbs.txt

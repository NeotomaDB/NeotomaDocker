#!/bin/bash
psql -h localhost -U postgres -c "DROP DATABASE IF EXISTS backup;"
psql -h localhost -U postgres -c "CREATE DATABASE backup;"
pg_dump -C -v -O -N ndb -h localhost -U postgres -d neotoma


# Export the database to a custom dump file from the parent database.
pg_dump -U postgres -h localhost -v -O -n ndb -F custom neotoma > temp.dump
dropdb -h localhost -U postgres temp
createdb  -h localhost -U postgres -T template0 temp
psql -h localhost -U postgres -d temp -c "CREATE EXTENSION postgis; CREATE EXTENSION pg_trgm;"
pg_restore -U postgres -h localhost -d temp constituent.dump

# Now, execute the cleaning script that removes data objects that are not directly
# related to the constituent database of interest (takes a long time):
psql -h localhost -U postgres -d temp -v dbid=3 -f cleanToDB.sql
pg_dump -U postgres -h localhost -v -O -n ndb -F custom temp > constituent.dump

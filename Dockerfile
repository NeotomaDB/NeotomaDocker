# build stage
FROM postgres/postgres as postgres

RUN  apt update \
  && apt install -y wget \
  && rm -rf /var/lib/apt/lists/*

# Pull in the database:
WORKDIR /dbruns

RUN mkdir dbout
RUN wget https://www.neotomadb.org/uploads/snapshots/neotoma_ndb_only_latest.tar --no-check-certificate
RUN tar -xf neotoma_ndb_only_latest.tar -C ./dbout
RUN createdb neotoma
RUN psql -d neotoma -c "CREATE EXTENSION postgis; CREATE EXTENSION pg_trgm;"
RUN psql -d neotoma -f ./dbout/neotoma_ndb_only_latest.sql

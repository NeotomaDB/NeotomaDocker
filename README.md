# Neotoma Docker and Bash utilities

This repository represents a set of utilities, supported by a Docker image of the Neotoma Database.

The repository is designed around a workflow in which a Docker image is created using the "latest" version of the Neotoma database, using a snapshot hosted on the [Neotoma Database Snapshots page](https://neotomadb.org/snapshots).

The main Docker image is stored in DockerHub (and supported by this public git repository). Associated utilites perform commandline or `psql` operations that are intended to occur periodically. By associating them with this repository and the docker container we can ensure that any operations do not affect the main Neotoma database, or any of its associated services.

# To Use Directly from the DockerHub
### TODO: Push image to a neotoma Dockerhub
```
docker run --name test -it -v $PWD/out:/out --rm -e POSTGRES_PASSWORD=postgres neotoma/neotoma_docker postgres
```

Note that the tags we are using can be modified:
`-- name` : Choose the name of your preference. We are setting the name to `test`.
`-v` : Mount the volume to our current path.
`--rm` : Remove the image once we finish using it
`-e POSTGRES_PASSWORD` : This is an environment variable, you can choose whichever password you want. We are setting it to `postgres`.

# To Build the Image
This GitHub repository includes a Dockerfile. If you would rather build the image in your local machine, use the following instructions:

1. To build the container clone or download this repository.
2. Navigate on your Terminal or bash to the root directory of this repository.
3. Run the following command:
```
docker build . --tag neotoma_postgres
```
You can name the tag anything you want, we have chosen `neotoma_postgres`
4. Run the container using:
```
docker run --name test -it -v $PWD/out:/out --rm -e POSTGRES_PASSWORD=postgres neotoma_docker postgres
```

In order to rebuild the Neotoma database, this Docker image uses the latest snapshot of the Neotoma Database.
This snapshot of the public version neotoma database was generated from PostgreSQL version 9.6.24.

The Dockerfile and regenbash.sh script run the following installation instructions.

1. Create new empty database named "neotoma".  You can use any name you like. Replace "superuser"
 with the user name of the account with superuser privileges

	createdb neotoma -U [superuser]

2. Enable requires extensions.

	psql -d neotoma -c "CREATE EXTENSION postgis;" -U [superuser]
	psql -d neotoma -c "CREATE EXTENSION pg_trgm;" -U [superuser]

3. Restore dump(.sql) file into the new database.

	psql -U [superuser] -d neotoma -f neotoma_ndb_only_2022-05-17.sql

4. To view database using command line interactive terminal:

	psql neotoma [superuser]

	Meta-command \d ("describe") will list all the tables in the publice schema. To view the schema (ndb) and tables in the database,
	expand the search path by entering the command:

		SET search_path TO 'ndb', public;


Notes on above commands:
	
	flag "-U":  username of the superuser that creates and then connects to new database

	flag "-d":  name of new database

	flag "-f":  name of snapshot file to be loaded into new database
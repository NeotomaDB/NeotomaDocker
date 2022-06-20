neotoma_ndb_latest.sql.gz 

This snapshot of the public version neotoma database was generated from PostgreSQL version 9.6.24 on June 14 2022.

The following installation instructions where tested on PostgreSQL version 12.9, using script regenbash.sh (mac and linux).
Alternatively, the commands can be entered directly in the command line. PostgreSQL must already be installed.

1. Unzip the snapshot file:

	gunzip neotoma_ndb_latest.sql.gz

2. Restore database using regenbash.sh.  For help, use: bash regenbash.sh --help

	bash regenbash.sh neotoma_ndb_latest.sql

	The script performs the following actions. A password prompt will appear at each step:
	
		The database "neotoma" is first dropped if it exists;
		The new "neotoma" is created;
		Extenesions are installled;
		The snapshot file (neotoma_ndb_latest.sql) is loaded into the new database.

3, Alternatively, instead of using the script, the commands can be entered directly via command line:

	dropdb neotoma
	createdb neotoma
	psql -d neotoma -c "CREATE EXTENSION postgis;"
	psql -d neotoma -c "CREATE EXTENSION pg_trgm;"
	psql -d neotoma -f neotoma_ndb_latest.sql



4. To view database using command line interactive terminal:

	psql neotoma username

	Meta-command \d ("describe") will list all the tables in the publice schema. To view the schema (ndb) and tables in the database,
	expand the search path by entering the command:

		SET search_path TO 'ndb', public;


	
	


	


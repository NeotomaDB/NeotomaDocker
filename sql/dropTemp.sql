SELECT * from pg_database where datname = 'temp';

-- Disallow new connections
UPDATE pg_database SET datallowconn = 'false' WHERE datname = 'temp';
ALTER DATABASE temp CONNECTION LIMIT 1;

-- Terminate existing connections
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'temp';

-- Drop database
DROP DATABASE temp;

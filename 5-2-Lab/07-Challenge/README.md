gcloud services enable servicenetworking.googleapis.com \
 datamigration.googleapis.com

sudo apt install postgresql-13-pglogical

sudo nano /etc/postgresql/13/main/postgresql.conf
add : 
#GSP918 - added configuration for pglogical database extension
wal_level = logical         # minimal, replica, or logical
max_worker_processes = 10   # one per database needed on provider node
                            # one per node needed on subscriber node
max_replication_slots = 10  # one per node needed on provider node
max_wal_senders = 10        # one per node needed on provider node
shared_preload_libraries = 'pglogical'
max_wal_size = 1GB
min_wal_size = 80MB
listen_addresses = '*'         # what IP address(es) to listen on, '*' is all

sudo nano /etc/postgresql/13/main/pg_hba.conf
add :
host    all all 0.0.0.0/0   md5

restart to load new conf : sudo systemctl restart postgresql@13-main

create user : 
sudo su - postgres
psql

\c postgres;
CREATE EXTENSION pglogical;
\c orders;
CREATE EXTENSION pglogical;

CREATE USER migration_user PASSWORD 'DMS_1s_cool!';
ALTER DATABASE orders OWNER TO migration_user;
ALTER ROLE migration_user WITH REPLICATION;

add permissions : 

\c postgres;
GRANT USAGE ON SCHEMA pglogical TO migration_user;
GRANT ALL ON SCHEMA pglogical TO migration_user;
GRANT SELECT ON pglogical.tables TO migration_user;
GRANT SELECT ON pglogical.depend TO migration_user;
GRANT SELECT ON pglogical.local_node TO migration_user;
GRANT SELECT ON pglogical.local_sync_status TO migration_user;
GRANT SELECT ON pglogical.node TO migration_user;
GRANT SELECT ON pglogical.node_interface TO migration_user;
GRANT SELECT ON pglogical.queue TO migration_user;
GRANT SELECT ON pglogical.replication_set TO migration_user;
GRANT SELECT ON pglogical.replication_set_seq TO migration_user;
GRANT SELECT ON pglogical.replication_set_table TO migration_user;
GRANT SELECT ON pglogical.sequence_state TO migration_user;
GRANT SELECT ON pglogical.subscription TO migration_user;

\c orders;
GRANT USAGE ON SCHEMA pglogical TO migration_user;
GRANT ALL ON SCHEMA pglogical TO migration_user;
GRANT SELECT ON pglogical.tables TO migration_user;
GRANT SELECT ON pglogical.depend TO migration_user;
GRANT SELECT ON pglogical.local_node TO migration_user;
GRANT SELECT ON pglogical.local_sync_status TO migration_user;
GRANT SELECT ON pglogical.node TO migration_user;
GRANT SELECT ON pglogical.node_interface TO migration_user;
GRANT SELECT ON pglogical.queue TO migration_user;
GRANT SELECT ON pglogical.replication_set TO migration_user;
GRANT SELECT ON pglogical.replication_set_seq TO migration_user;
GRANT SELECT ON pglogical.replication_set_table TO migration_user;
GRANT SELECT ON pglogical.sequence_state TO migration_user;
GRANT SELECT ON pglogical.subscription TO migration_user;

\c orders;
GRANT USAGE ON SCHEMA public TO migration_user;
GRANT ALL ON SCHEMA public TO migration_user;
GRANT SELECT ON public.distribution_centers TO migration_user;
GRANT SELECT ON public.inventory_items TO migration_user;
GRANT SELECT ON public.order_items TO migration_user;
GRANT SELECT ON public.products TO migration_user;
GRANT SELECT ON public.users TO migration_user;

all tables need primary key : 

ALTER TABLE public.inventory_items ADD PRIMARY KEY(id);
\q 
exit
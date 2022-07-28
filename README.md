# postgresql-backup-restore-fs
Service to backup and/or restore a PostgreSQL database to/from a local filesystem directory

## How to use it
1. Create a directory on the filesystem to hold your backups
2. Supply all appropriate environment variables
3. Run a backup and check your directory for that backup

### Environment variables
`MODE` Valid values: `backup`, `restore`

`DB_HOST` hostname of the database server

`DB_NAME` name of the database

`DB_OPTIONS` optional arguments to supply to the backup or restore commands

`DB_ROOTPASSWORD` password for the `DB_ROOTUSER`

`DB_ROOTUSER` database administrative user, typically "postgres" for PostgreSQL databases

`DB_USERPASSWORD` password for the `DB_USER`

`DB_USER` user that accesses the database (PostgreSQL "role")

`BACKUP_DIR` e.g., _/path/to/database-backups_ **NOTE: no trailing slash**

>**Versioning of the backup file is left as an exercise for the user.  This script will overwrite an existing backup file.**

## Docker Hub
This image is built automatically on Docker Hub as [silintl/postgresql-backup-restore-fs](https://hub.docker.com/r/silintl/postgresql-backup-restore-fs/)

## Playing with it locally
You'll need [Docker](https://www.docker.com/get-docker), [Docker Compose](https://docs.docker.com/compose/install/), and [Make](https://www.gnu.org/software/make/).

1. cd .../postgres-backup-restore-fs
2. mkdir ./mybackups
3. cp -p test/world.sql.gz ./mybackups
4. `make db`  # creates the Postgres DB server
5. `make restore`  # restores the DB dump file
6. `docker ps -a`  # get the Container ID of the exited restore container
7. `docker logs <containerID>`  # review the restoration log messages
8. `make backup`  # create a new DB dump file
9. `docker ps -a`  # get the Container ID of the exited backup container
10. `docker logs <containerID>`  # review the backup log messages
11. `make restore`  # restore the DB dump file from the new backup
12. `docker ps -a`  # get the Container ID of the exited restore container
13. `docker logs <containerID>`  # review the restoration log messages
14. `make clean`  # remove containers and network
15. `docker volume ls`  # find the volume ID of the Postgres data container
16. `docker volume rm <volumeID>`  # remove the data volume
17. `docker images`  # list existing images
18. `docker image rm <imageID ...>`  # remove images no longer needed

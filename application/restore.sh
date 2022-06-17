#!/usr/bin/env sh

STATUS=0

echo "postgresql-backup-restore-fs: restore: Started"

# Ensure the database user exists.
echo "postgresql-backup-restore-fs: checking for DB user ${DB_USER}"
result=$(psql --host=${DB_HOST} --username=${DB_ROOTUSER} --command='\du' | grep ${DB_USER})
if [ -z "${result}" ]; then
    result=$(psql --host=${DB_HOST} --username=${DB_ROOTUSER} --command="create role ${DB_USER} with login password '${DB_USERPASSWORD}' inherit;")
    if [ "${result}" != "CREATE ROLE" ]; then
        message="Create role command failed: ${result}"
        echo "postgresql-backup-restore-fs: FATAL: ${message}"
        exit 1
    fi
fi

# Delete database if it exists.
echo "postgresql-backup-restore-fs: checking for DB ${DB_NAME}"
result=$(psql --host=${DB_HOST} --username=${DB_ROOTUSER} --list | grep ${DB_NAME})
if [ -z "${result}" ]; then
    message="Database "${DB_NAME}" on host "${DB_HOST}" does not exist."
    echo "postgresql-backup-restore-fs: INFO: ${message}"
else
    echo "postgresql-backup-restore-fs: deleting database ${DB_NAME}"
    result=$(psql --host=${DB_HOST} --dbname=postgres --username=${DB_USER} --command="DROP DATABASE ${DB_NAME};")
    if [ "${result}" != "DROP DATABASE" ]; then
        message="Create database command failed: ${result}"
        echo "postgresql-backup-restore-fs: FATAL: ${message}"
        exit 1
    fi
fi

echo "postgresql-backup-restore-fs: copying database ${DB_NAME} backup from ${BACKUP_DIR}"
start=$(date +%s)
cp ${BACKUP_DIR}/${DB_NAME}.sql.gz /tmp/${DB_NAME}.sql.gz || STATUS=$?
end=$(date +%s)

if [ $STATUS -ne 0 ]; then
    echo "postgresql-backup-restore-fs: FATAL: Copy backup of ${DB_NAME} from ${BACKUP_DIR} returned non-zero status ($STATUS) in $(expr ${end} - ${start}) seconds."
    exit $STATUS
else
    echo "postgresql-backup-restore-fs: Copy backup of ${DB_NAME} from ${BACKUP_DIR} completed in $(expr ${end} - ${start}) seconds."
fi

echo "postgresql-backup-restore-fs: decompressing backup of ${DB_NAME}"
start=$(date +%s)
gunzip -f /tmp/${DB_NAME}.sql.gz || STATUS=$?
end=$(date +%s)

if [ $STATUS -ne 0 ]; then
    echo "postgresql-backup-restore-fs: FATAL: Decompressing backup of ${DB_NAME} returned non-zero status ($STATUS) in $(expr ${end} - ${start}) seconds."
    exit $STATUS
else
    echo "postgresql-backup-restore-fs: Decompressing backup of ${DB_NAME} completed in $(expr ${end} - ${start}) seconds."
fi

echo "postgresql-backup-restore-fs: restoring ${DB_NAME}"
start=$(date +%s)
psql --host=${DB_HOST} --username=${DB_ROOTUSER} --dbname=postgres ${DB_OPTIONS}  < /tmp/${DB_NAME}.sql || STATUS=$?
end=$(date +%s)

if [ $STATUS -ne 0 ]; then
    echo "postgresql-backup-restore-fs: FATAL: Restore of ${DB_NAME} returned non-zero status ($STATUS) in $(expr ${end} - ${start}) seconds."
    exit $STATUS
else
    echo "postgresql-backup-restore-fs: Restore of ${DB_NAME} completed in $(expr ${end} - ${start}) seconds."
fi

echo "postgresql-backup-restore-fs: restore: Completed"
exit $STATUS

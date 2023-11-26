#!/bin/bash
# ------------------------------------------------------
# Required config/cred files:
# - /home/web/restic/restic.conf
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# export RESTIC_REPOSITORY=s3:https://s3.us-east-1.amazonaws.com/bucket-name
#
# - /home/web/restic/pw
# This file should only contain the restic password
#
# - /home/web/restic/${DB_NAME_A}.sqlpwd (one for each db)
# [mysqldump]
# user=
# password=
#
# Then set required permission and recommended ownership:
# sudo chmod 600 /home/web/restic/${DB_NAME_A}.sqlpwd && sudo chown $USER:nogroup /home/web/restic/${DB_NAME_A}.sqlpwd
# ------------------------------------------------------
# Log filename
LOG_DATE=$(date +'%Y%m%d%H%M%S')
LOG_FILEPATH="/home/web/git/simple-restic-backups/log/${LOG_DATE}.log"

# Number of snapshots to keep
SNAPSHOTS_TO_KEEP=14

# PATH TO
CONFIG_FILE="/home/web/restic/restic.conf"
PASSWORD_FILE="/home/web/restic/pw"

BACKUP_THIS_DIR="/home/"

# Remove a specific snapshot
SPECIFIC_SNAPSHOT=""

# ------------------------------------------------------
LOG_DIR="$(dirname "${LOG_FILEPATH}")"

# Everything below will go to the file $LOG_FILEPATH:
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$LOG_FILEPATH 2>&1

# Make the log dir
mkdir -p $LOG_DIR

# Get config variables
. $CONFIG_FILE

# First, back up mysql db and other directories to a local restic repository
# This is handled by CloudPanel, so no longer needed here
# for db in ${DB_NAMES[@]}
# do
#   mysqldump --defaults-extra-file="/home/web/restic/${db}.sqlpwd" --databases ${db} --no-tablespaces > /home/web/backups/${db}.sql
#   echo "mysqldump: Backing up ${db} to /home/web/backups/${db}.sql"
# done

# Backup to s3
echo "\nStarting backup..."
restic backup $BACKUP_THIS_DIR --password-file $PASSWORD_FILE

# Prune old backups
echo "\nRemoving old backups..."
restic forget --keep-last $SNAPSHOTS_TO_KEEP --prune --password-file $PASSWORD_FILE

# Log snapshots
echo "\nLogging snapshots..."
restic snapshots --password-file $PASSWORD_FILE

# Remove specific snapshots
if [ -z "$SPECIFIC_SNAPSHOT" ]; then
  :
else
  echo "\nRemoving Snapshot id ${SPECIFIC_SNAPSHOT}..."
  restic forget $SPECIFIC_SNAPSHOT --password-file $PASSWORD_FILE
fi

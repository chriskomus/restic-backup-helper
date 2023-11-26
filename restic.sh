#!/bin/bash
# ------------------------------------------------------
# Required config/cred files:
# - /home/web/restic/restic.conf
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# export RESTIC_REPOSITORY=s3:https://s3.us-east-1.amazonaws.com/bucket-name
# export DB_NAME_A=
# export DB_USERNAME_A=
# export DB_PASSWORD_A=
# export DB_NAME_B=
# export DB_USERNAME_B=
# export DB_PASSWORD_B=
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

# Get config variables
. /home/web/restic/restic.conf

# First, back up mysql db and other directories to a local restic repository
# for db in ${DB_NAMES[@]}
# do
#   mysqldump --defaults-extra-file="/home/web/restic/${db}.sqlpwd" --databases ${db} --no-tablespaces > /home/web/backups/${db}.sql
#   echo "mysqldump: Backing up ${db} to /home/web/backups/${db}.sql"
# done

# Next, backup to s3
restic backup /home/ --password-file /home/web/restic/pw
restic forget --keep-last 1 --prune --password-file /home/web/restic/pw
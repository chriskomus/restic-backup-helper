#!/bin/bash
# ------------------------------------------------------
# RESTIC BACKUP - Config
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
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
LOG_DATE=$(date +'%Y%m%d%H%M%S')

# Log filepath
LOG_FILEPATH="${SCRIPT_DIR}/log/${LOG_DATE}.log"

# Number of snapshots to keep
SNAPSHOTS_TO_KEEP=1

# PATH TO
CONFIG_FILE="/home/web/restic/restic.conf"
PASSWORD_FILE="/home/web/restic/pw"
DB_BACKUP_DIR="/home/web/backups/"
DB_CREDS_DIR="/home/web/restic/"
BACKUP_THIS_DIR="/home/"
RESTORE_TO_THIS_DIR="/tmp/restore/"

# ------------------------------------------------------
# Get config variables
. $CONFIG_FILE

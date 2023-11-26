#!/bin/bash
# ------------------------------------------------------
# RESTIC HELPER
# A script to simplify backups, restores, snapshot deletes
# and data validation.
#
# Edit config.sh to set the location of the restic
# password, aws config, backup and restore directories.
#
# This script can:
# - Backup a directory
# - Restore a specific snapshot
# - Delete a specific snapshot
# - List all files in a snapshot
# - List all snapshots
# - Verify the integrity of the backups
#
# Set up Cron Job:
# sudo crontab -e
#
# Add line to backup daily at 5am:
# 0 5 * * * /home/web/git/simple-restic-backups/restic.sh --backup
# ------------------------------------------------------

# Get config
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
. ${SCRIPT_DIR}/config.sh

# Make the log dir
mkdir -p $(dirname "${LOG_FILEPATH}")

# ------------------------------------------------------

log_to_file() {
  echo "Writing output to logfile: ${LOG_FILEPATH}"
  exec 3>&1 4>&2
  trap 'exec 2>&4 1>&3' 0 1 2 3
  exec 1>$LOG_FILEPATH 2>&1
}

# Function to display help information
display_help() {
  echo "Usage: $0 --backup|--delete|--restore|--files --id <id> | --snapshots | --help"
  echo "Options:"
  echo "  --help      : Show help information"
  echo "  --backup    : Perform a backup, prune and verify data"
  echo "  --snapshots : List all snapshots"
  echo "  --files     : List all files in a snapshot (requires --id)"
  echo "  --delete    : Delete a snapshot (requires --id)"
  echo "  --restore   : Restore a snapshot (optional --id, otherwise restores latest backup)"
  echo "  --id <id>   : Specify snapshot ID"
}

display_snapshots() {
  echo "Listing all snapshots..."
  restic snapshots --password-file $PASSWORD_FILE
}

verify_backups() {
  echo "Performing backup data verification..."
  restic check --password-file $PASSWORD_FILE
  echo "Verification completed."
}

# ------------------------------------------------------

echo "Script starting..."

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root if backing up outside of ~"
fi

# Default values
backup_requested=0
delete_requested=0
restore_requested=0
files_requested=0
snapshots_requested=0
snapshot_id=""

# Parse flags and their arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  "--help")
    display_help
    exit 0
    ;;
  "--backup")
    ((backup_requested++))
    ;;
  "--delete")
    ((delete_requested++))
    ;;
  "--restore")
    ((restore_requested++))
    ;;
  "--files")
    ((files_requested++))
    ;;
  "--snapshots")
    snapshots_requested=1
    ;;
  "--id")
    shift
    if [ -z "$1" ]; then
      echo "Error: Missing snapshot ID after --id flag."
      display_help
      exit 1
    fi
    snapshot_id="$1"
    ;;
  *)
    echo "Error: Invalid argument '$1'."
    display_help
    exit 1
    ;;
  esac
  shift
done

# Check if more than one of the exclusive flags are used
exclusive_flags_count=$((backup_requested + delete_requested + restore_requested + files_requested))

if [ $exclusive_flags_count -gt 1 ]; then
  echo "Error: Only one of --backup, --delete, --restore, or --files can be used at a time."
  display_help
  exit 1
fi

# Perform actions based on the requested operations
if [ $backup_requested -eq 1 ]; then
  log_to_file
  # This is handled by CloudPanel, so no longer needed here
  # for db in ${DB_NAMES[@]}; do
  #   mysqldump --defaults-extra-file="${DB_CREDS_DIR}${db}.sqlpwd" --databases ${db} --no-tablespaces > ${DB_BACKUP_DIR}${db}.sql
  #   echo "mysqldump: Backing up ${db} to ${DB_BACKUP_DIR}${db}.sql"
  # done
  echo "Performing backup..."
  restic backup $BACKUP_THIS_DIR --password-file $PASSWORD_FILE
  echo "Backup completed."
  display_snapshots
  echo "Pruning old backups..."
  restic forget --keep-last $SNAPSHOTS_TO_KEEP --prune --password-file $PASSWORD_FILE
  echo "Pruning completed."
  display_snapshots
  verify_backups
fi

if [ $snapshots_requested -eq 1 ]; then
  log_to_file
  display_snapshots
fi

if [ $files_requested -eq 1 ]; then
  if [ -z "$snapshot_id" ]; then
    echo "Error: --files requires --id to be specified."
    display_help
    exit 1
  else
    log_to_file
    echo "Listing all files in snapshot with ID: $snapshot_id..."
    restic ls --long $snapshot_id --password-file $PASSWORD_FILE
  fi
fi

if [ $delete_requested -eq 1 ]; then
  if [ -z "$snapshot_id" ]; then
    echo "Error: --delete requires --id to be specified."
    display_help
    exit 1
  else
    log_to_file
    echo "Deleting snapshot with ID: $snapshot_id"
    restic forget $snapshot_id --password-file $PASSWORD_FILE
    echo "Snapshot deleted."
    display_snapshots
    verify_backups
  fi
fi

if [ $restore_requested -eq 1 ]; then
  log_to_file
  verify_backups
  if [ -z "$snapshot_id" ]; then
    echo "Restoring latest snapshot"
    restic restore latest --target $RESTORE_TO_THIS_DIR --password-file $PASSWORD_FILE
    echo "Snapshot restored."
  else
    echo "Restoring snapshot with ID: $snapshot_id"
    restic restore $snapshot_id --target $RESTORE_TO_THIS_DIR --password-file $PASSWORD_FILE
    echo "Snapshot restored."
  fi
fi

# If no flags were provided, display help
if [ $exclusive_flags_count -eq 0 ] && [ $snapshots_requested -eq 0 ]; then
  display_help
  exit 0
else
  echo "SCRIPT COMPLETED."
fi

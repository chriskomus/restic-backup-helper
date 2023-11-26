# Restic Helper

A script to simplify backups, restores, snapshot deletes, and data validation using Restic.

## Setup

### Installation and Configs

Install and set up [Restic](https://restic.net/).

Optional: [Configure Restic to store backup snapshots in AWS S3](https://restic.readthedocs.io/en/latest/080_examples.html).

Edit `config.sh` to set the location of the Restic password, AWS/cloud config, backup, and restore directories.

Create a Restic password file containing only the password.

Create a Restic config file with the following:
```sh
export AWS_ACCESS_KEY_ID=*****
export AWS_SECRET_ACCESS_KEY=*****
export RESTIC_REPOSITORY=s3:https://s3.us-east-1.amazonaws.com/bucket-name
export DB_NAMES=(dbname-a dbname-b dbname-c)
```

```sh
[mysqldump]
user=username
password="usedoublequotes"
```

### Cron Job Setup

To set up a Cron Job:
```sh
sudo crontab -e
```

Append the following line (this will back up every day at 5am):
```sh
0 5 * * * /home/username/git/simple-restic-backups/restic.sh --backup
```

## Usage
This script enables you to:

Backup a directory
Restore a specific snapshot
Delete a specific snapshot
List all files in a snapshot
List all snapshots
Verify the integrity of backups
Usage Examples

### Backup
```sh
./restic.sh --backup
```

### List all snapshots
```sh
./restic.sh --snapshots
```

### List all files in a snapshot
```sh
./restic.sh --files --id <snapshot_id>
```

### Delete a snapshot
```sh
./restic.sh --delete --id <snapshot_id>
```

### Restore latest snapshot
```sh
./restic.sh --restore
```

### Restore a specific snapshot
```sh
./restic.sh --restore --id <snapshot_id>
```

## Notes
Ensure proper permissions or run as root for backup operations outside the user's home directory.
Use only one of the following flags at a time: --backup, --delete, --restore, or --files.
For --restore, if no snapshot ID is provided, it restores the latest backup.
For detailed information on flags and usage, run:

```sh
./restic.sh --help
```

Note: This script assumes familiarity with Restic and its usage.

Remember to edit the script's `config.sh` file with your specific configurations before use.
# Required config/cred files:
# - ~/restic/restic.config
#
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# export RESTIC_REPOSITORY=
#
# - ~/restic/creds.txt
#
# This file should only contain the restic password

# First, back up mysql db and other directories to a local restic repository


# Next, backup to s3
source ~/restic/restic.config
restic backup ~ --password-file ~/restic/creds.txt
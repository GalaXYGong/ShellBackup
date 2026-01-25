#!/bin/bash
CONFIG_FILE="$(dirname "$0")"/ShellBackup.conf

if [ -f $CONFIG_FILE ]; then
    source $CONFIG_FILE
else
    echo "Error: Can't find config file $CONFIG_FILE"
    exit 1
fi

if mountpoint -q "$MOUNTING_POINT"; then
    echo "$MOUNTING_POINT has been mounted. ShellBackup will start"
else
    echo "mounting $MOUNTING_POINT"
    mount $MOUNTING_POINT
    if [ $? -ne 0 ]; then
        echo "ERROR: $MOUNTING_POINT can not be mounted ShellBackup won't start"
        exit 1
    fi
fi

DATE=$(date +%Y-%m-%d)
BACKUP_PATH="$PARENT_DIR/changed/$DATE"
NOW=$(date +%Y%m%d_%H%M)

mkdir -p $TARGET_DIR

rsync -av --delete \
      --backup \
      --backup-dir="$BACKUP_PATH" \
      --suffix="_$NOW" \
      "$SOURCE_DIR" "$TARGET_DIR"


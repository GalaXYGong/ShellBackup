#!/bin/bash
CONFIG_FILE="$(dirname "$0")"/ShellBackup.conf
TASKS="$(dirname "$0")"/Tasks.conf
DATE=$(date +%Y-%m-%d)
NOW=$(date +%Y%m%d_%H%M)

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

if [ -f $TASKS ]; then
    while IFS="|" read -r NAME PARENT_DIR TARGET_DIR SOURCE_DIR; do
        if [[ $NAME == *\#*  ]]; then
            echo "Skipping comment: $NAME"
            continue
        fi
        if [[ -z "$PARENT_DIR" || -z "$TARGET_DIR" ]]; then
            echo "Skip Non-Tasks: $NAME"
            continue
        fi
        echo "Handleing $NAME..."
        # mkdir -p $TARGET_DIR
        SOURCE_DIR=$(eval echo $SOURCE_DIR)
        TARGET_DIR=$(eval echo $TARGET_DIR)
        PARENT_DIR=$(eval echo $PARENT_DIR)
        TARGET_DIR="$PARENT_DIR/$TARGET_DIR"
        BACKUP_PATH="$PARENT_DIR/changed/$DATE"
        echo $PARENT_DIR
        echo $SOURCE_DIR
        echo $TARGET_DIR
        echo $BACKUP_PATH
        rsync -av --delete \
              --backup \
              --backup-dir="$BACKUP_PATH" \
              --suffix="_$NOW" \
              --exclude '.git' \
              "$SOURCE_DIR" "$TARGET_DIR"
    done < $TASKS
else
    echo "Error: Can't find Tasks file $TASKS"
    exit 1
fi







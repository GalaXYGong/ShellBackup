#!/bin/bash
CONFIG_FILE="$(dirname "$0")"/ShellBackup.conf
TASKS="$(dirname "$0")"/Tasks.conf
DATE=$(date +%Y-%m-%d)
NOW=$(date +%Y%m%d_%H%M)
CONTENT_FOLDER="Content"
EXCLUDE_FILE="$(dirname "$0")"/exclude_list.txt
EXCLUDE_OPT=""

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

# when there is no exclude_list.txt, we give it empty thing
if [ -f "$EXCLUDE_FILE" ]; then
    EXCLUDE_OPT="--exclude-from=$EXCLUDE_FILE"
fi

if [ -f $TASKS ]; then
    while IFS="|" read -r NAME PARENT_DIR SOURCE_DIR; do
        if [[ $NAME == *\#*  ]]; then
            echo "Skipping comment: $NAME"
            continue
        fi
        if [[ -z "$PARENT_DIR" || -z "SOURCE_DIR" ]]; then
            echo "Skip Non-Tasks: $NAME"
            continue
        fi
        echo "Handleing $NAME..."
        # mkdir -p $TARGET_DIR
        NAME=$(eval echo $NAME)
        PARENT_DIR=$(eval echo $PARENT_DIR)
        PROJECT_DIR="$PARENT_DIR/$NAME"
        TARGET_DIR="$PROJECT_DIR/$CONTENT_FOLDER"
        SOURCE_DIR=$(eval echo $SOURCE_DIR)
        BACKUP_PATH="$PROJECT_DIR/Changed/$DATE"
        echo "------------------------------------------"
        echo -e "This is TASK $NAME.\n  Backup Content Directory \`$CONTENT_FOLDER\` will be under Parent Directory:\n    \`$TARGET_DIR\`.\n  Changed Files and Folders will be under:\n    \`$TARGET_DIR/Changed/$DATE\`"
        echo "------------------------------------------"
        # echo $PARENT_DIR
        # echo $SOURCE_DIR
        # echo $TARGET_DIR
        # echo $BACKUP_PATH
        mkdir -p $TARGET_DIR
        time -p \
            rsync -ah --delete \
              --backup \
              --backup-dir="$BACKUP_PATH" \
              --suffix="_$NOW" \
              $EXCLUDE_OPT \
              --stats \
              --no-links \
              "$SOURCE_DIR" "$TARGET_DIR"
    done < $TASKS
else
    echo "Error: Can't find Tasks file $TASKS"
    exit 1
fi






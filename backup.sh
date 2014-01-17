#!/bin/sh
#

LOGPATH="/var/log/backup/"
LOG=/dev/stdout

BACKUPDIR="/mnt/backup"

## backup variables
UUID="3a0d8332-8c96-4160-83a0-48e369955c1d"
OSDIR="$BACKUPDIR/OS/Chunky2"
MEDDIR="$BACKUPDIR/Media"
EXCLUDE_FILE="/etc/backup-exclude.conf"

function usage() {
  echo 1>&2 Usage: $0 "[-s|--system] OR [-m|--media] OR [-dm|--debugmount] [-du|--umount] [-h|--help]"
  echo 1>&2 "Specify -s or -m to perform a backup"
}

# Make sure we're running as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# CLI Argument defaults
MOUNT=1;
UMOUNT=1;
OSBACKUP=0;
MEDIABACKUP=0;

while [ $# -gt 0 ]; do
  case $1 in
    -s|--system )
      OSBACKUP=1
      LOG=$LOGPATH/OS.log
      ;;
    -m|--media )
      MEDIABACKUP=1;
      LOG=$LOGPATH/OS.log
      ;;
    -dm|--debugmount )
      UMOUNT=0;
      ;;
    -du|--umount )
      MOUNT=0;
      ;;
    -h|--help )
      usage
      exit 0
      ;;
    *)
      echo "`date`: Error, bad argument: $1, aborting." >> $LOG 2>&1 3>&1;
      usage
      exit 1
      ;;
  esac
  shift
done


echo "" > $LOG
echo "-------------------------------------------">> $LOG

################## First mount everything ##########################
if [ $MOUNT -eq 1 ]; then
  [ -d $BACKUPDIR ] || mkdir -p $BACKUPDIR;
  echo "`date`: /bin/mount /dev/disk/by-uuid/$UUID $BACKUPDIR" >> $LOG;
  /bin/mount /dev/disk/by-uuid/$UUID $BACKUPDIR >> $LOG 2>&1 3>&1;
  if [ "$?" != "0" ]; then
    echo "`date`: ERROR: Could not mount device $UUID to $BACKUPDIR" >> $LOG;
  fi
fi

######################## Backup #######################################
if [ $MEDIABACKUP -eq 1 ]; then
  [ -d $MEDIADIR ] || mkdir -p $MEDIADIR;
  /usr/bin/rsync -av --delete --delete-excluded --human-readable \
    --exclude tmp/ /media/* $MEDDIR >> $LOG 2>&1 3>&1 
  if [ "$?" != "0" ]; then
    echo "`date`: ERROR: Could not backup Media data" >> $LOG
  fi
elif [ $OSBACKUP -eq 1 ]; then
  [ -d $OSDIR ] || mkdir -p $OSDIR;
  /usr/bin/rsync -av  --delete --delete-excluded --human-readable \
    --exclude-from $EXCLUDE_FILE \
    /*           $OSDIR >> $LOG 2>&1 3>&1
  if [ "$?" != "0" ]; then
    echo "`date`: ERROR: Could not backup OS data" >> $LOG
  fi
fi

# # ################## Last, unmount everything ##########################
# if [ $UMOUNT -eq 1 ]; then
#   echo "`date`: /bin/umount $BACKUPDIR" >> $LOG
#   /bin/umount $BACKUPDIR  >> $LOG 2>&1 3>&1
#   if [ "$?" != "0" ]; then
#     echo "`date`: ERROR: Could not unmount device at $BACKUPDIR" >> $LOG;
#   fi
# fi

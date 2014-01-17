#!/bin/sh
# Assumed to be run as 'root' user

LOGPATH="/var/log/backup/"

## Network backup variables (using fuse on top of vfat system to get ext2)
BACKUPDIR="/mnt/backup"

## USB backup variables
USBDIR=$BACKUPDIR
UUID="3a0d8332-8c96-4160-83a0-48e369955c1d"
OSDIR="$USBDIR/OS/Chunky2"
MEDDIR="$USBDIR/Media"

# CLI Argument defaults
UMOUNT=0;
BACKUP=0;
USBMOUNT=0;
USBUMOUNT=0;
MEDIABACKUP=0;
MAINDIR=$USBDIR;
while [ $# -gt 0 ]; do
  case $1 in
    -u|--usb )
      USBMOUNT=1;
      BACKUP=1;
      USBUMOUNT=1;
      ;;
    -m|--media )
      MEDIABACKUP=1;
      LOG="/root/backup_media.log";
      ;;
    -dm|--debugmount )
      USBMOUNT=1;
      ;;
    -du|--umount )
      USBUMOUNT=1
      ;;
    -db|--backup )
      BACKUP=1
      ;;
    -h|--help )
      echo "-u|--usb: Backup filesystem via USB connection.";
      echo "          performs mount, backup, and unmount.";
      ;;
    *)
      echo "`date`: Error, bad argument: $1, aborting." >> $LOG 2>&1 3>&1;
      ;;
  esac
  shift
done


echo "" > $LOG
echo "-------------------------------------------">> $LOG

################## First mount everything ##########################
if [ $USBMOUNT -eq 1 ]; then
  echo "`date`: /sbin/mount /dev/disk/by-uuid/$UUID $USBDIR" >> $LOG;
  /sbin/mount /dev/disk/by-uuid/$UUID $USBDIR >> $LOG 2>&1 3>&1;
  if [ "$?" != "0" ]; then
    echo "`date`: ERROR: Could not mount usb device $UUID to $USBDIR" >> $LOG;
  fi
fi

######################## Backup #######################################
if [ $BACKUP -eq 1 ]; then
  if [ $MEDIABACKUP -eq 1 ]; then
    /usr/bin/rsync -avL --delete --delete-excluded --human-readable \
      --exclude tmp/ --exclude video/mythtv/                      \
      /mnt/media/* $MEDDIR >> $LOG 2>&1 3>&1 
    if [ "$?" != "0" ]; then
      echo "`date`: ERROR: Could not backup Media data" >> $LOG
    fi
  else
    /usr/bin/rsync -av  --delete --delete-excluded --human-readable \
      --exclude-from /root/os_exclude.txt                         \
      /*           $OSDIR >> $LOG 2>&1 3>&1
    if [ "$?" != "0" ]; then
      echo "`date`: ERROR: Could not backup OS data" >> $LOG
    fi
  fi
fi

# ################## Last, unmount everything ##########################
if [ $USBUMOUNT -eq 1 ]; then
  echo "`date`: /sbin/umount $USBDIR" >> $LOG
  /sbin/umount $USBDIR  >> $LOG 2>&1 3>&1
  if [ "$?" != "0" ]; then
    echo "`date`: ERROR: Could not unmount usb device at $USBDIR" >> $LOG;
  fi
fi

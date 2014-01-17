#!/bin/sh
# Assumed to be run as 'root' user

LOG="/var/log/backup/OS.log"

## Network backup variables (using fuse on top of vfat system to get ext2)
BACKUPDIR="/mnt/backup"
FUSEDIR="$BACKUPDIR/hd"
SAMBADIR="$BACKUPDIR/samba"
LOOPDIR="$BACKUPDIR/loops"

# Number of loop disks
LOOPDISKS=12

## USB backup variables
USBDIR=$BACKUPDIR
UUID="3a0d8332-8c96-4160-83a0-48e369955c1d"
OSDIR="$USBDIR/OS/Chunky"
MEDDIR="$USBDIR/Media"

# CLI Argument defaults
MOUNT=0;
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
	-ds|--samba )
	    MAINDIR=$SAMBADIR
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

elif [ $MOUNT -eq 1 ]; then
    # SAMBA
    if [ "$MAINDIR" == "$SAMBADIR" ]; then
	/sbin/mount -t smbfs -o user=dave,password=jambony1 \\\\router\\Default $MAINDIR >> $LOG 2>&1 3>&1
	if [ "$?" != "0" ]; then
            echo "`date`: ERROR: Could not mount hard drive via samba" >> $LOG
            exit 1
	fi
    fi
    # LOOP DEVICES
    for ((I=0; I<$LOOPDISKS; I++)); do
	/bin/mkdir -p $LOOPDIR/disk$I;
	/sbin/mount -t ext3 -o loop=/dev/loop$I $MAINDIR/os/chunky/disk$I.raw $LOOPDIR/disk$I >> $LOG 2>&1 3>&1
	if [ "$?" != "0" ]; then
	    echo "`date`: ERROR: Could not mount loop device $I" >> $LOG
	    exit 2
	fi
    done
    # MOUNT COMBINED LOOP DEVICES
    /usr/local/bin/mhddfs $LOOPDIR/disk* $FUSEDIR >> $LOG 2>&1 3>&1
    if [ "$?" != "0" ]; then
	echo "`date`: ERROR: Could not mount fuse device via mhddfs" >> $LOG
	exit 3
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

elif [ $UMOUNT -eq 1 ]; then
    sleep 1;
    # UNMOUNT COMBINED LOOP DEVICES
    /sbin/umount $FUSEDIR >> $LOG 2>&1 3>&1
    if [ "$?" != "0" ]; then
        echo "`date`: ERROR: Could not unmount fuse device" >> $LOG
        #exit 4
    fi
    sleep 1
    # UNMOUNT LOOP DEVICES
    for ((I=0; I<$LOOPDISKS; I++)); do
        /sbin/umount -d $LOOPDIR/disk$I >> $LOG 2>&1 3>&1
        if [ "$?" != "0" ]; then
     	    echo "`date`: ERROR: Could not umount loop device $I" >> $LOG
     	    #exit 5
        fi
    done
    sleep 1
    # UNMOUNT SAMBA
    if [ "$MAINDIR" == "$SAMBADIR" ]; then
	/sbin/umount $MAINDIR >> $LOG 2>&1 3>&1
	if [ "$?" != "0" ]; then
            echo "`date`: ERROR: Could not umount hard drive via samba" >> $LOG
            #exit 6
	fi
    fi
fi

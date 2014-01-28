#!/bin/bash
#
# COPYRIGHT
# -----------------
# Dave S Desrochers 2014. All rights reserved. Licensed software.
#
# COPYING PERMISSION
# -----------------
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Brief Description
# -----------------
# Simple backup script for media files. Useful when tied to udev.
# That is, when plugging in a specific USB drive, will trigger a
# backup to it.
#

. /etc/config/usbdiskmount

# Keep in mind this is a running log file
[ -d $LOGPATH ] || mkdir -p $LOGPATH
LOG=$LOGPATH/usbdiskmount.log

# Make sure we're not running as root
if [ "$(id -u)" == "0" ]; then
  echo "This script should not be running as root" 1>&2
  exit 1
fi

function usage() {
  echo 1>&2 Usage: $0 "{/dev/diskIdPartitionId}"
  echo 1>&2 "Backs up your media files.. with sound!"
}

function media_backup() {
  /usr/bin/rsync -avL --delete --delete-excluded --human-readable \
    --exclude-from $MEDIA_EXCLUDE_FILE \
    /media/* "$DRIVE_MOUNTPOINT/media" >> $LOG 2>&1 3>&1
}

function play
{
  case $1 in
    "INSERT" )
      $SNDPLAYER $SNDPATH/usbdisk_insert.wav
      ;;
    "FAIL" )
      $SNDPLAYER $SNDPATH/usbdisk_fail.wav
      ;;
    "REMOVE" )
      $SNDPLAYER $SNDPATH/usbdisk_remove.wav
      ;;
    *)
      echof "Error, bad argument in play() function, aborting.";
      ;;
  esac
}

function get-uuid
{
  ls -l /dev/disk/by-uuid/ |
  grep "$1" |
  sed 's_[^#]* \([^#]*\) ->[^#]*_\1_'
}

function echof
{
  echo "`date`: $1" 2>&1 >> $LOG
}

## Backup get-uuid in case something gets effed with udev
function get-uuid2
{
  /sbin/blkid /dev/$1 | /usr/bin/awk '{print $4}' | /usr/bin/sed 's/UUID="\(.*\)"/\1/'
}


# Local Variables
DRIVE_KERNEL="$1"
DRIVE_UUID=$(get-uuid "$DRIVE_KERNEL")

echo "" >> $LOG
echo "---------------------------------------------------------------------" >> $LOG

# Error checking
if [ "$DRIVE_KERNEL" == '' ]
then
  play "FAIL"
  echof "Error defining \$DRIVE_KERNEL on $DRIVE_KERNEL, aborting."
  exit 1
fi
if [ "$DRIVE_UUID" == '' ]
then
  play "FAIL"
  echof "Error defining \$DRIVE_UUID on $DRIVE_KERNEL, aborting."
  exit 1
fi

DRIVE_DEVICEPATH="/dev/$DRIVE_KERNEL"
if [ "$DRIVE_DEVICEPATH" == '' ]
then
  play "FAIL"
  echof "Error defining \$DRIVE_DEVICEPATH on $DRIVE_KERNEL, aborting."
  exit 1
fi

echof "Attempting to mount $DRIVE_KERNEL"
/usr/bin/pmount $POPTS $DRIVE_DEVICEPATH 2>&1 >> $LOG
if [ "$?" != "0" ]
then
  play "FAIL"
  echof "Failed to mount"
  exit 1
fi
sleep 1s
DRIVE_MOUNTPOINT=`df | grep "^/dev/$DRIVE_KERNEL" | awk '{print $6}'`
if [ "$DRIVE_MOUNTPOINT" == '' ]
then
  play "FAIL"
  echof "Error defining \$DRIVE_MOUNTPOINT, aborting."
  exit 1
fi


play "INSERT"
echof "sucessfully mounted $DRIVE_KERNEL"
if [ "$DRIVE_UUID" == "$MY_DRIVE_UUID" ]; then

  sleep 1s
  $(media_backup) && \
    echof "sucessfully backed up media files on $DRIVE_KERNEL.. unmounting.."

  sleep 1s
  /usr/bin/pumount $DRIVE_MOUNTPOINT
  if [ "$?" != "0" ]; then
    echof "Could not unmount $DRIVE_MOUNTPOINT. You must unmount manually"
  else
    play "REMOVE"
  fi
fi

echof "DONE"

exit $?

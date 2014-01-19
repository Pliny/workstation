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

function play
{
  case $1 in
    "INSERT" )
      /usr/local/bin/mplayer -ao oss -really-quiet $SNDPATH/usbdisk_insert.wav
      ;;
    "FAIL" )
      /usr/local/bin/mplayer -ao oss -really-quiet $SNDPATH/usbdisk_fail.wav
      ;;
    "REMOVE" )
      /usr/local/bin/mplayer -ao oss -really-quiet $SNDPATH/usbdisk_remove.wav
      ;;
    *)
      echo "`date`: Error, bad argument in play() function, aborting." 2>&1 >> $LOG;
      ;;
  esac
}

function get-uuid
{
  ls -l /dev/disk/by-uuid/ |
  grep "$1" |
  sed 's_[^#]* \([^#]*\) ->[^#]*_\1_'
}

## Backup get-uuid in case something gets effed with udev
function get-uuid2
{
  /sbin/blkid /dev/$1 | /usr/bin/awk '{print $4}' | /usr/bin/sed 's/UUID="\(.*\)"/\1/'
}


drive_kernel="$1"
drive_uuid=`get-uuid "$drive_kernel"`

echo "" >> $LOG
echo "---------------------------------------------------------------------" >> $LOG

if [ "$drive_kernel" == '' ]
then
  play "FAIL"
  echo "`date`: Error defining \$drive_kernel on $1, aborting." 2>&1 >> $LOG
  exit 1
fi
if [ "$drive_uuid" == '' ]
then
  play "FAIL"
  echo "`date`: Error defining \$drive_uuid on $1, aborting." 2>&1 >> $LOG
  exit 1
fi

drive_devicepath="/dev/$drive_kernel"
if [ "$drive_devicepath" == '' ]
then
  play "FAIL"
  echo "`date`: Error defining \$drive_devicepath on $1, aborting." 2>&1 >> $LOG
  exit 1
fi

echo "`date`: Attempting to mount $1" 2>&1 >> $LOG
/usr/bin/pmount $drive_devicepath 2>&1 >> $LOG
if [ "$?" != "0" ]
then
  play "FAIL"
  echo "`date`: Failed to mount" 2>&1 >> $LOG
  exit 1
fi
sleep 1s
drive_mountpoint=`df | grep "^/dev/$drive_kernel" | awk '{print $6}'`
if [ "$drive_mountpoint" == '' ]
then
  play "FAIL"
  echo "Error defining \$drive_mountpoint, aborting." >&2
  exit 1
fi 


play "INSERT"
echo "`date`: sucessfully mounted $1" 2>&1 >> $LOG
if [ "$drive_uuid" == "$MY_DRIVE_UUID" ]
then

  sleep 1s
  /usr/bin/rsync -avL --delete --delete-excluded  \
    --exclude tmp/                             \
    --exclude video/mythtv/                    \
    /mnt/media/* "$drive_mountpoint/media" 2>&1 >> $LOG && \

    echo "`date`: sucessfully backed up media files on $1.. unmounting.." 2>&1 >> $LOG

  /usr/bin/pumount $drive_mountpoint
  if [ "$?" != "0" ]
  then
    echo "`date`: Could not unmount $1. You must unmount manually" 2>&1 >> $LOG
  else
    play "REMOVE"
  fi
fi


exit $?  

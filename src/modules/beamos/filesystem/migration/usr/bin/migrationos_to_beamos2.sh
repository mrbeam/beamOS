#!/bin/bash

BASEDIR="/usr/bin"

# This script is used to flash the Beam OS 2 to the SD-Card.
# Then the Mr Beam will start to Beam OS 2.

# This script uses migration.sh script

# Usage:
#   Flash the SD-Card
#   Mount the SD-Card
#   Restore Sensitive Data
#   Set LED Status Success/Fail
#   Shutdown the device

timestamp()
{
 date +"%Y-%m-%d %T"
}

do_exit()
{
  RET_CODE="$?"
  echo "$(timestamp) $0: Exitting. ${RET_CODE}"
  if [ "$RET_CODE" -eq 0 ]; then
    echo "$0: Normal exiting."
    sudo bash ${BASEDIR}/migration.sh set-status success
  else
    echo "$0: Exiting with error code [${RET_CODE}]"
    sudo bash ${BASEDIR}/migration.sh set-status fail orange
  fi
}


###############################################
# Constants
###############################################
IMAGE_DIR="/home/pi/image"
BEAMOS2_IMAGE="${IMAGE_DIR}/beamos2.wic.bz2"


###############################################
# Main function
###############################################

# Set trap before EXIT
trap do_exit EXIT

#   Flash the SD-Card
echo "$(timestamp) $0: Flashing the SD-Card"
sudo bash ${BASEDIR}/migration.sh set-status in-progress orange
sudo bash ${BASEDIR}/migration.sh flash beamos2 sd-card
exit_code=$?
if [ "$exit_code" -ne 0 ]; then
  echo "$(timestamp) $0: Flashing the SD-Card failed"
  exit 100
fi

#   Mount the SD-Card
echo "$(timestamp) $0: Mounting the SD-Card"
sudo bash ${BASEDIR}/migration.sh set-status in-progress orange
sudo bash ${BASEDIR}/migration.sh mount sd-card
exit_code=$?
if [ "$exit_code" -ne 0 ]; then
  echo "$(timestamp) $0: Mounting the SD-Card failed"
  exit 100
fi

#   Restore Sensitive Data
echo "$(timestamp) $0: Restoring Sensitive Data"
sudo bash ${BASEDIR}/migration.sh set-status in-progress orange
sudo bash ${BASEDIR}/migration.sh restore-data
exit_code=$?
if [ "$exit_code" -ne 0 ]; then
  echo "$(timestamp) $0: Restoring Sensitive Data failed"
  exit 100
fi

# Shutdown the device
echo "$(timestamp) $0: Shutdown the device"
sudo bash ${BASEDIR}/migration.sh set-status success
sudo bash ${BASEDIR}/migration.sh shutdown
exit_code=$?
if [ "$exit_code" -ne 0 ]; then
  echo "$(timestamp) $0: Shutdown the device failed"
  exit 100
fi

exit 0

#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

rm -rf read_out.eep read_out.txt

MODEL=$(cat /proc/device-tree/model)
RASPI='Raspberry Pi'
ROCK='ROCK PI'
echo "Board $MODEL"

GENERAT=read_out.eep

if [[ "$MODEL" == *$RASPI* ]];  then
./eepflash.sh -r -f=$GENERAT -t=24c256 -d=0 
elif [[ "$MODEL" == *$ROCK* ]];  then
./eepflash.sh -r -f=$GENERAT -t=24c256 -d=2  -a=50
else
 echo "test"
fi 


if [ $? = 0 ]; 
then
    echo    "Reading data from EEPROM succeeded"
else
    echo    "Failed to read data from EEPROM"
    exit 1
fi

echo    "Converting..."

OUT=read_out.txt
./eepdump    $GENERAT    $OUT 
if [ $? = 0 ]; then
    echo    "Conversion success"
else
    echo    "conversion failed"
    exit 1
fi

cat $OUT

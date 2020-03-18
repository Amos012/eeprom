#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

rm -rf  num.txt  write_in.eep read_out.eep read_out.txt 

MODELA=`cat /proc/device-tree/model`
MODELB='Raspberry Pi'
MODELC='ROCK PI'


echo "Board $MODELA"

FILENAME=num.txt         #创建序列号的TXT文件
if [ ! -d $FILENAME  ];then
  touch $FILENAME
else
  echo dir exist
fi

read -p "Please scan the serial number:" serialnum
if test -w  $FILENAME && test -n $serialnum
then
    echo $serialnum > $FILENAME
    echo "Write the successfully"
else
    echo "Write the failure"
fi

read -p "Please scan the MAC address:" MACnum
if test -w  $FILENAME && test -n $MACnum
then
    echo  $MACnum   >> $FILENAME
    echo "Write the successfully"
else
    echo "Write the failure"
fi



GENERAT=write_in.eep        #生成写入eeprom的.eep 文件
./eepmake  eeprom_settings.txt   $GENERAT   -c   $FILENAME 
if [ $? = 0 ] 
then
    echo    "Generate $GENERAT file succeeded"
else
    echo    "Failed to generate $GENERAT file"
    exit 1
fi

EMPTY=blank.eep       #创建清空eeprom的.eep文件
if [ ! -d $EMPTY  ];then
    touch $EMPTY
else
    echo dir exist
fi

if [[ "$MODELA" == *$MODELB* ]];then
    echo "正在写入树莓派"
    dd if=/dev/zero ibs=1k count=4 of=$EMPTY      
    ./eepflash.sh -w -f=$EMPTY -t=24c256 -d=0 
elif [[ "$MODELA" == *$MODELC* ]]; then
    echo "正在写入ROCK"
    dd if=/dev/zero ibs=1 count=256 of=blank.eep      #目前rock pi4只支持at24c02的驱动，所以只有256byte大小
  ./eepflash.sh -w -f=$EMPTY -t=24c256 -d=2  -a=50
fi

if [ $? = 0 ]; 
  then
    echo    "EEPROM cleared successfully"
  else
    echo    "Failed to empty EEPROM"
    exit 1
fi

if [[ "$MODELA" == *$MODELB* ]]
  then
     echo "正在写入树莓派"
  ./eepflash.sh -w -f=$GENERAT -t=24c256 -d=0 
elif [[ "$MODELA" == *$MODELC* ]]
  then
    echo "正在写入ROCK"
  ./eepflash.sh -w -f=$GENERAT -t=24c256 -d=2  -a=50
fi 


 if [ $? = 0 ]
 then
     echo    "Write the EEPROM succeeded"
 else
     echo    "Failed to write the EEPROM"
     exit 1
 fi

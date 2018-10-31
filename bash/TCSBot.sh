#!bin/sh
APP_PATH=/home/mfs/apps/tcserrorbot/prod

java -jar $APP_PATH/dist/TCSMonitor.jar $APP_PATH/


DATE=$(date +%Y%m%d)
YEST=`expr $DATE - 1`

file=`ls $APP_PATH/AppLogs/*$YEST*`

if [  -f "$file" ]
then
    echo "Removing Yesterdays Logfile..."$file
    rm $file
    
fi
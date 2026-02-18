#! bin/bash

source ./common.sh

app_name="catalogue"
check_root
app_setup
nodejs_setup


# mongodb setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "copying mongo repo file"

sudo dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "installing mongodb mongosh client"


Index=$(mongosh --host $MONGODB_HOST --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")') &>>$LOGS_FILE

if [ $Index -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOGS_FILE
    VALIDATE $? "loading products data to catalogue database"
else
    echo -e "$Y $(date "+%y-%m-%d %H:%M:%S")| Products already loaded in catalogue database $Y SKIPPING $N" &>>$LOGS_FILE
fi

app_restart


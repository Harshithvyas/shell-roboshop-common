#!/bin/bash 

source ./common.sh
app_name=catalogue

app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Install MongoDB client"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install MongoDB client"

INDEX=$(mongodb.harshithdaws86s.fun --quiet --eval "db.getMongo().getDBNames().indexof('catalogue')")
if [ $INDEX -le 0 ]; then
   mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
   VALIDATE $? "Load $app_name products"
else
    echo -e " $app_name product already loaded ... $Y SKIPPING $N"
fi

app_restart
print_total_time

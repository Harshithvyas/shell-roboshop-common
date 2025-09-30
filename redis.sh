#!/bin/bash

source ./common.sh

check_root

dnf module disable $app_name -y &>>$LOG_FILE
VALIDATE $? "Disabling Default Redis"
dnf module enable $app_name:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling Redis 7"
dnf install $app_name -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/$app_name/$app_name.conf
VALIDATE $? "Allowing Remote connection to Redis"

systemctl enable $app_name &>>$LOG_FILE
VALIDATE $? "Enabling Redis"
systemctl start $app_name
VALIDATE $? "starting Redis" &>>$LOG_FILE

print_total_time
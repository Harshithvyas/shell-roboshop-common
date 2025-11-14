#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld
VALIDATE $? "Enabling and Starting MySQL Server"

mysql_secure_installation --set-root-pass Roboshop &>>$LOG_FILE
VALIDATE $? "Setting root password for MySQL Server"

print_total_time

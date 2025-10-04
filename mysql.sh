#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $2 "Installing MySQL Server"
systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld
VALIDATE $? "Enabling and Starting MySQL Server"
mysql_server_installation --set-root-pass Roboshop &>>$LOG_FILE
VALIDATE $2 "Setting root password to MySQL Server"
print_total_time
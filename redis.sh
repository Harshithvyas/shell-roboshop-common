#!/bin/bash

source ./common.sh
check_root

app_name=redis   # define Redis service name

# Disable/Enable Redis module safely
dnf module disable $app_name -y &>>$LOG_FILE || true
VALIDATE 0 "Disabling Default Redis"

dnf module enable $app_name:7 -y &>>$LOG_FILE || true
VALIDATE 0 "Enabling Redis 7"

dnf install $app_name -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

# Allow remote connection
CONF_FILE="/etc/$app_name/$app_name.conf"
if [ -f "$CONF_FILE" ]; then
    sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' $CONF_FILE
    VALIDATE $? "Allowing Remote connection to Redis"
else
    echo -e "$R ERROR:: $CONF_FILE not found $N" | tee -a $LOG_FILE
fi

# Enable and start Redis service
systemctl enable $app_name &>>$LOG_FILE
VALIDATE $? "Enabling Redis"

systemctl start $app_name &>>$LOG_FILE
VALIDATE $? "Starting Redis"

# Print execution time
print_total_time

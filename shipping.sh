#!/bin/bash

source ./common.sh
app_name=shipping

check_root
app_setup
java_setup
systemd_setup  

mysql -h $MYSQL_HOST -uroot -pRoboshop@1 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
   mysql -h  $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
   mysql -h  $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
   mysql -h  $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "Shipping data is already 
fi

app_restart
print_total_time


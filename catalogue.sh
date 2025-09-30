#!/bin/bash
source ./common.sh
check_root
app_name=catalogue

# Create .service file if missing
if [ ! -f "$SCRIPT_DIR/$app_name.service" ]; then
cat <<EOF | sudo tee $SCRIPT_DIR/$app_name.service
[Unit]
Description=Catalogue Service
After=network.target

[Service]
User=ec2-user
Environment=MONGODB_HOST=$MONGODB_HOST
ExecStart=/bin/node /app/server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF
fi

# App setup
app_setup
nodejs_setup
systemd_setup

# MongoDB repo
cp $SCRIPT_DIR/mongo-repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy MongoDB repo"

# Install MongoDB client
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install MongoDB client"

# Load catalogue products if DB doesn't exist
INDEX=$(mongosh --host $MONGODB_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ "$INDEX" -eq -1 ]; then
   mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
   VALIDATE $? "Load $app_name products"
else
    echo -e " $app_name product already loaded ... $Y SKIPPING $N"
fi

# Restart app
app_restart
print_total_time


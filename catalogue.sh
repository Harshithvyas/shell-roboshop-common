#!/bin/bash

# Set script directory and source common.sh
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/common.sh"

# Ensure script is run as root
check_root

# App name
app_name=catalogue

# Ensure systemd service file exists
if [ ! -f "$SCRIPT_DIR/$app_name.service" ]; then
cat <<EOF | sudo tee "$SCRIPT_DIR/$app_name.service"
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

# Setup application
app_setup
nodejs_setup
systemd_setup

# Copy MongoDB repo file
if [ -f "$SCRIPT_DIR/mongo-repo" ]; then
    cp "$SCRIPT_DIR/mongo-repo" /etc/yum.repos.d/mongo.repo
    VALIDATE $? "Copy MongoDB repo"
else
    echo -e "$Y Warning: mongo-repo file not found, skipping copy $N"
fi

# Install MongoDB client
dnf install mongodb-mongosh -y &>>"$LOG_FILE"
VALIDATE $? "Install MongoDB client"

# Load catalogue products if DB doesn't exist
INDEX=$(mongosh --host $MONGODB_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ "$INDEX" -eq -1 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>"$LOG_FILE"
    VALIDATE $? "Load $app_name products"
else
    echo -e " $app_name product already loaded ... $Y SKIPPING $N"
fi

# Restart application
app_restart

# Print total execution time
print_total_time

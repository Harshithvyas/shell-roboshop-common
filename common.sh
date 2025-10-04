#!/bin/bash

# Get root user ID and colors
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Logging setup
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(basename "$0" | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.harshithdaws86s.fun
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)   # absolute path

# Create log folder if missing
mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" &>>$LOG_FILE

# Function to check root privileges
check_root(){
  if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR:: Please run this script with root privilege $N"
    exit 1
  fi
}

# Function to validate command exit status
VALIDATE() {
  if [ $1 -eq 0 ]; then
    echo -e " $2 ... $G SUCCESS $N" | tee -a $LOG_FILE
  else
    echo -e " $2 ... $R FAILURE $N" | tee -a $LOG_FILE
    exit 1
  fi
}

# NodeJS setup
nodejs_setup(){
  cd /app
  dnf module disable nodejs -y &>>$LOG_FILE
  VALIDATE $? "Disabling NodeJS"

  dnf module enable nodejs:20 -y &>>$LOG_FILE
  VALIDATE $? "Enabling NodeJS 20"

  dnf install nodejs -y &>>$LOG_FILE
  VALIDATE $? "Installing NodeJS"

  npm install &>>$LOG_FILE
  VALIDATE $? "Install dependencies"
}

java_setup(){
  dnf install maven -y &>>$LOG_FILE
  VALIDATE $? "Installing Maven"
  mvn clean package &>>$LOG_FILE
  VALIDATE $? "Packing the application"
  mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
  VALIDATE $? "Renaming the artifact"
}

# App setup
app_setup(){
  mkdir -p /app
  VALIDATE $? "Creating app directory"

  curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
  VALIDATE $? "Downloading $app_name application"

  cd /app
  VALIDATE $? "Changing to app directory"

  rm -rf /app/*
  VALIDATE $? "Removing existing code"

  unzip /tmp/$app_name.zip &>>$LOG_FILE
  VALIDATE $? "Unzipping $app_name"
}

# Systemd setup
systemd_setup(){
  if [ -f "$SCRIPT_DIR/$app_name.service" ]; then
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copy systemctl service"

    systemctl daemon-reload
    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enable $app_name"
  else
    echo -e "$Y Warning: $app_name.service not found, skipping systemd setup $N" | tee -a $LOG_FILE
  fi
}

# Restart app
app_restart(){
  systemctl restart $app_name &>>$LOG_FILE
  VALIDATE $? "Restarted $app_name"
}

# Print total execution time
print_total_time(){
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
}

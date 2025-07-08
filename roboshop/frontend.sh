#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER

echo "Script started executing at $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run the script with root access $N" | tee -a $LOG_FILE
else
    echo -e "$G Running script with root access $N" | tee -a $LOG_FILE
    exit 1
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ........... $G Success $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ........... $R Failure $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nginx -y &>> $LOG_FILE
VALIDATE $? "Disable nginx"

dnf module enable nginx:1.24 -y &>> $LOG_FILE
VALIDATE $? "Enable nginx 1.24"

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Install nginx"

systemctl enable nginx  &>> $LOG_FILE
systemctl start nginx  &>> $LOG_FILE
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/*  &>> $LOG_FILE
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE
VALIDATE $? "Download frontend content"

cd /usr/share/nginx/html  
unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "unzip components"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE &>> $LOG_FILE
VALIDATE $? "Remove default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>> $LOG_FILE
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx  &>> $LOG_FILE
VALIDATE $? "Restarting nginx"
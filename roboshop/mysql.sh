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

echo "Please enter password to setup"
read -s MYSQL_ROOT_PASSWORD


VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ........... $G Success $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ........... $R Failure $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf install mysql-server -y
VALIDATE $? "Install mysql"

systemctl enable mysqld
VALIDATE $? "Enable mysql"

systemctl start mysqld  
VALIDATE $? "Start mysql"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "Setting mysql password and Connect to mysql server"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE


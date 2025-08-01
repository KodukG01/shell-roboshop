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

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installing Node JS"

id roboshop

if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
    VALIDATE $? "Adding user roboshop"
else
   echo "user added nothing to do .......$Y Skipping $N"
fi
mkdir -p  /app 
VALIDATE $? "Creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $LOG_FILE
VALIDATE $? "Downloading cart"

rm -rf /app/*
cd /app 
unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "unzipping cart"

npm install &>> $LOG_FILE
VALIDATE $? "Installing Dependencies"

systemctl daemon-reload &>> $LOG_FILE
systemctl enable cart  &>> $LOG_FILE
systemctl start cart &>> $LOG_FILE
VALIDATE $? "Start cart" 

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
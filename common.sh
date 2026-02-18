#! bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/Shell-Roboshop"
SCRIPT_DIR=$pwd
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.learn-devops.cloud

echo "script started excuting at: $(date "+%y-%m-%d %H:%M:%S")"  | tee -a $LOGS_FILE


check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e "$R please run this script with root user access $N" | tee -a $LOGS_FILE
        exit 1
    fi    
}

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then

        echo -e "$(date "+%y-%m-%d %H:%M:%S")$2....$R failure $N"   | tee -a $LOGS_FILE
        exit 1

    else 
        echo -e "$(date "+%y-%m-%d %H:%M:%S")$2....$G Success $N"    | tee -a $LOGS_FILE
    fi

}
nodejs_setup(){
        dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "disabling nodejs module"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "enabling nodejs 20 module"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "installing nodejs"

    npm install &>>$LOGS_FILE
    VALIDATE $? "installing catalogue dependencies"
}

app_setup(){

        id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "adding roboshop user"

    else
        echo -e "$Y roboshop user already exists, skipping user creation $N" | tee -a $LOGS_FILE
    fi  

    cd /app &>>$LOGS_FILE
    VALIDATE $? "navigating to application directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOGS_FILE
    VALIDATE $? "downloading $app_name code"

    rm -rf /app/* &>>$LOGS_FILE
    VALIDATE $? "cleaning application directory"

    unzip /tmp/$app_name.zip &>>$LOGS_FILE
    VALIDATE $? "extracting $app_name code" 
}

system_steup(){
    cp "$SCRIPT_DIR/$app_name.service" /etc/systemd/system/$app_name.service &>>$LOGS_FILE
    VALIDATE $? "copying $app_name systemd service file"

    systemctl daemon-reload &>>$LOGS_FILE
    VALIDATE $? "reloading systemd daemon"

    systemctl enable $app_name &>>$LOGS_FILE
    VALIDATE $? "enabling $app_name service"

    systemctl start $app_name &>>$LOGS_FILE
    VALIDATE $? "starting $app_name service"
}

app_restart(){
    systemctl restart $app_name &>>$LOGS_FILE
    VALIDATE $? "restarting $app_name service"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Total time taken to execute the script: $G $TOTAL_TIME seconds" | tee -a $LOGS_FILE
}
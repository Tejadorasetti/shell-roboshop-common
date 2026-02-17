#! bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/Shell-Roboshop"
SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
START_TIME=$(date +%s)

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

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Total time taken to execute the script: $G $TOTAL_TIME seconds" | tee -a $LOGS_FILE
}
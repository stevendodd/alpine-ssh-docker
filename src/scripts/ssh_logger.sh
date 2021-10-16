#!/bin/ash

path="/etc/ssh"
fifoFile="$path/ssh_fifo"

## Check if pipe exists or fail
if [[ ! -p $fifoFile ]];then
   mkfifo $fifoFile
   [[ ! -p $fifoFile ]] && echo "ERROR: Failed to create FIFO file" && exit 1
fi

## Monitor the FIFO file and store the SSHD logs
while true
do
    if read line; then
       printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line" >> "/var/log/auth.log"

       if printf '%s\n' "$line" | grep -Fqe "Accepted"; then
          echo -e "To: ${EMAIL}\nSubject: Alpine SSH Login\nFrom:${EMAIL}\n\n$line\n" | sendmail -t
       fi
    fi
done <"$fifoFile"
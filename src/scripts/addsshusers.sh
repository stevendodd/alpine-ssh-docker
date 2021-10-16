#!/bin/ash

cd /home
tar xvf users.tar
rm users.tar

for USER in *; do
    if [ -d "$USER" ]; then
        PASSWORD=`python3 -c "import os; print(os.urandom(20))"`
        mkdir -p ${USER}/.ssh
        mv ${USER}/authorized_keys ${USER}/.ssh/authorized_keys 
        adduser -h /home/${USER} -D -s /bin/sh ${USER}
        echo "${USER}:${PASSWORD}" | chpasswd
        chown -R ${USER}:${USER} ${USER}
        chmod 700 /home/${USER}/.ssh
        chmod 600 /home/${USER}/.ssh/authorized_keys
    fi
done

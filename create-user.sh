#!/bin/bash
# docker-entrypoint.sh

# Check if the user already exists
if ! id "$MY_USER" &>/dev/null; then
    # Create the user with the specified UID and GID
    adduser --disabled-password --gecos "" --uid $MY_UID $MY_USER
    
    # Set the user's password
    if [ -n "$MY_PASSWORD" ]; then
        echo "${MY_USER}:${MY_PASSWORD}" | chpasswd
    fi
fi

cp -a /root/. /home/$MY_USER
chown -R $MY_USER:$MY_USER /home/$MY_USER
chsh -s /bin/zsh $MY_USER

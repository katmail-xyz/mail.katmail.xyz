#!/bin/bash

sudo useradd -M --shell /bin/false dovecot
sudo useradd -M --shell /bin/false dovenull
sudo useradd -m --shell /bin/false vmail

if [ ! -f /var/log/dovecot.log ]; then
    sudo touch /var/log/dovecot.log
    sudo chown vmail:vmail /var/log/dovecot.log
fi

if [ ! -f /var/log/dovecot-info.log ]; then
    sudo touch /var/log/dovecot-info.log
    sudo chown vmail:vmail /var/log/dovecot-info.log
fi

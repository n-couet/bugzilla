#!/bin/bash

#set timezone
echo "Europe/Paris" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# PHP
apt-get update && apt-get upgrade
apt-get install -y perl g++ apache2

# Git
apt-get install -y git

# MySQL
debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'
apt-get -y install mysql-server

# Accept MySql connections from outside
sed -i 's/bind-address/#bind-address = 0.0.0.0 #/g' /etc/mysql/my.cnf
echo "bind-address 0.0.0.0" >> /etc/mysql/my.cnf
mysql -u root -pvagrant -e "GRANT ALL PRIVILEGES  on *.* to root@'%' IDENTIFIED BY 'vagrant'; FLUSH PRIVILEGES;"
service mysql restart

# Applying agentfowarding
echo -e "Host *\n    ForwardAgent yes" > /home/vagrant/.ssh/config

# Apache conf
VM_VHOST="
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /vagrant
    <Directory /vagrant>
        Options All
        AllowOverride All
        Require all granted
        AddHandler cgi-script .cgi
        DirectoryIndex index.cgi index.html
    </Directory>
</virtualHost>
"

VM_CONF_FILE="/etc/apache2/sites-available/bugzilla.conf"

[[ -f "$VM_CONF_FILE" ]] || touch "$VM_CONF_FILE"
[[ ! -f "$VM_CONF_FILE" ]] || echo "$VM_VHOST" > "$VM_CONF_FILE"

a2enmod rewrite
a2enmod cgi
a2ensite bugzilla.conf
a2dissite 000-default.conf

service apache2 reload

# configure xdebug
libpath=$(find / -name 'xdebug.so' 2> /dev/null);
hostip=$(netstat -r | grep default | cut -d ' ' -f 10);
printf "zend_extension=\"$libpath\"\nxdebug.remote_enable=1\nxdebug.remote_handler=\"dbgp\"\nxdebug.remote_port=9001\nxdebug.remote_autostart=1\nxdebug.remote_mode=\"req\"\nxdebug.remote_host=\"$hostip\"\nxdebug.idekey=\"vagrant\"\nxdebug.remote_log=\"/var/log/xdebug/xdebug.log\"\n" > /etc/php5/mods-available/xdebug.ini
service apache2 restart

# We add gitlab to known hosts
ssh-keyscan -H gitlab.rvip.fr > /etc/ssh/ssh_known_hosts
ssh-keyscan -H github.com > /etc/ssh/ssh_known_hosts

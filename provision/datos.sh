#!/bin/bash
ORIGEN='/vagrant/provision/'
export DEBIAN_FRONTEND=noninteractive

# Actualizacion e instalacion
apt-get update
apt-get -y install vim 

# Archivos base "a fuego"
#cp $ORIGEN/bashrc /etc/skel/.bashrc
#cp $ORIGEN/bashrc /home/vagrant/.bashrc
#cp $ORIGEN/bashrc-root /root/.bashrc
#cp $ORIGEN/vimrc /etc/vim/vimrc

### MySQL para Wordpress ###
mysqlword="xyzzy"
apt-get -q -y install mysql-server
mysqladmin -u root password $mysqlword

mysql -u root -p$mysqlword -e"CREATE DATABASE wpdatabase;" 
mysql -u root -p$mysqlword -e"use wpdatabase;"

mysql -u root -p$mysqlword -e"CREATE USER wpuser@localhost;"

mysql -u root -p$mysqlword -e"SET PASSWORD FOR wpuser@localhost= PASSWORD('dbpassword');"

#### IMPORTAR DUMP DE LA BD ####
gunzip < /vagrant/provision/wpdatabase.sql.gz | mysql -u root -pxyzzy wpdatabase

#### ESTABLECER PERMISOS SOBRE LA MISMA PARA USUARIO wpuser ####
mysql -u root -p$mysqlword -e"GRANT ALL PRIVILEGES ON wpdatabase.* TO wpuser@10.0.0.222 IDENTIFIED BY 'dbpassword';"
mysql -u root -p$mysqlword -e"FLUSH PRIVILEGES;"

#### Copiar config MySQL ####
cp /vagrant/provision/my.cnf /etc/mysql/
chmod 644 /etc/mysql/my.cnf

service mysql restart

### Usuario operador ###
password="password" # your chosen password
encrypted_password=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$password")
sudo useradd -m -p $encrypted_password -G sudo -s /bin/bash operador

### SSH config: puerto 4000, permitRootLogin without password ###
cp /vagrant/provision/sshd_config /etc/ssh/

#### DNS ####
cp -rpP $ORIGEN/hosts_datos /etc/hosts




#!/bin/bash
ORIGEN='/vagrant/provision/'
export DEBIAN_FRONTEND=noninteractive

# Actualizacion e instalacion
apt-get update
apt-get -y install vim 

### Usuario operador ###
password="password" # your chosen password
encrypted_password=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$password")
useradd -m -p $encrypted_password -G sudo -s /bin/bash operador

### Usuario respaldo ###
password="respaldo"
encrypted_password=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$password")
useradd -m -p $encrypted_password -s /bin/bash respaldo

### Certificados para ssh ###
mkdir /home/respaldo/.ssh

cp -rPp $ORIGEN/id_rsa $ORIGEN/id_rsa.pub /home/respaldo/.ssh
cp -rPp $ORIGEN/authorized_keys_control /home/respaldo/.ssh/authorized_keys
cp -rPp $ORIGEN/known_hosts_control /home/respaldo/.ssh/known_hosts

chown -R respaldo:respaldo /home/respaldo/.ssh
chmod 700 /home/respaldo/.ssh
chmod 600 /home/respaldo/.ssh/*

/etc/init.d/ssh restart

### DNS ####
cp -rpP $ORIGEN/hosts_control /etc/hosts # ATENCION: FALTA COPIAR DESDE LA VIRTUAL PARA AFUERA
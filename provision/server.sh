#!/bin/sh
ORIGEN='/vagrant/provision/'

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y install vim apache2 openssh-server libapache2-mod-php5 php5 php-pear php5-mysql php5-gd

### Usuario operador ###
password="password" 
encrypted_password=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$password")
useradd -m -p $encrypted_password -G sudo -s /bin/bash operador


### SSH config: puerto 4000, permitRootLogin without password ###
cp -rpP /vagrant/provision/sshd_config /etc/ssh/

## Authorized Keys ##
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

#cp -rPp /vagrant/provision/id_rsa.pub /vagrant/provision/id_rsa  

cat ~/.ssh/id_rsa >> /root/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

cp -rPp ~/.ssh/id_rsa ~/.ssh/id_rsa.pub /vagrant/provision/
cp -rPp /root/.ssh/authorized_keys /vagrant/provision/authorized_keys_control

/etc/init.d/ssh restart

#### Resolucion DNS ###
cp -rpP $ORIGEN/hosts_server /etc/hosts

## Instalar wordpress ###
wget http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
cp ./wordpress/wp-config-sample.php ./wordpress/wp-config.php

configFile="./wordpress/wp-config.php"

### Datos viejos ###
d1="define('DB_NAME', 'database_name_here');"
d2="define('DB_USER', 'username_here');"
d3="define('DB_PASSWORD', 'password_here');"
d4="define('DB_HOST', 'localhost');"

### Datos nuevos ###
s1="define('DB_NAME', 'wpdatabase');"
s2="define('DB_USER', 'wpuser');"
s3="define('DB_PASSWORD', 'dbpassword');"
s4="define('DB_HOST', '10.0.0.210');"
sed -i "s/$d1/$s1/g" $configFile
sed -i "s/$d2/$s2/g" $configFile
sed -i "s/$d3/$s3/g" $configFile
sed -i "s/$d4/$s4/g" $configFile

mv ./wordpress/ /var/www/html/
chown -R www-data:www-data /var/www/html/wordpress

service apache2 restart
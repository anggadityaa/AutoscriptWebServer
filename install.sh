#!/bin/bash
echo " "
echo " "
echo "d8888b. db    db d8b   db d8b   db d888888b d8b   db  d888b    .d8888.  .o88b. d8888b. d888888b d8888b. d888888b "
echo "88  '8D 88    88 888o  88 888o  88   '88'   888o  88 88' Y8b   88'  YP d8P  Y8 88  '8D   '88'   88  '8D '~~88~~' "
echo "88oobY' 88    88 88V8o 88 88V8o 88    88    88V8o 88 88        '8bo.   8P      88oobY'    88    88oodD'    88    "
echo "88'8b   88    88 88 V8o88 88 V8o88    88    88 V8o88 88  ooo     'Y8b. 8b      88'8b      88    88~~~      88    "
echo "88 '88. 88b  d88 88  V888 88  V888   .88.   88  V888 88. ~8~   db   8D Y8b  d8 88 '88.   .88.   88         88    "
echo "88   YD ~Y8888P' VP   V8P VP   V8P Y888888P VP   V8P  Y888P    '8888Y'  'Y88P' 88   YD Y888888P 88         YP    "
echo " "

echo " "
if [ "$EUID" -ne 0 ]
  then
  echo -e "[\e[31mFAIL\e[0m] Script was not run as root!"
  exit
else
  echo -e "[\e[32m OK \e[0m] Script was run by root!"
fi
echo " "

apt update
apt install expect -y
apt upgrade -y
apt install aptitude

lampp () {
echo "Menginstall LAMP stack"
echo " "
read -p "Please enter the desired MySQL root password: " -s MYSQL_ROOT_PASS
echo " "
echo "Menginstall Apache"
aptitude install -y apache2 >> lamp-install.log

echo " "
echo "Menginstall MariaDB (MySQL)"
aptitude install -y mariadb-server mariadb-client >> lamp-install.log
[ ! -e /usr/bin/expect ]
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none): \"
send \"n\r\"
expect \"Change the root password? \[Y/n\] \"
send \"y\r\"
expect \"New password: \"
send \"$MYSQL_ROOT_PASS\r\"
expect \"Re-enter new password: \"
send \"$MYSQL_ROOT_PASS\r\"
expect \"Remove anonymous users? \[Y/n\] \"
send \"y\r\"
expect \"Disallow root login remotely? \[Y/n\] \"
send \"y\r\"
expect \"Remove test database and access to it? \[Y/n\] \"
send \"y\r\"
expect \"Reload privilege tables now? \[Y/n\] \"
send \"y\r\"
expect eof
")

echo " "
echo "Menginstall PHP"
aptitude install -y php libapache2-mod-php php-mysql php-redis php-zip >> lamp-install.log
service apache2 restart >> lamp-install.log

echo " "
echo "Menginstall PhpMyAdmin"
if [ ! -f /etc/phpmyadmin/config.inc.php ];
then
# MYSQL_ROOT_PASS='1234567890'

  echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_ROOT_PASS" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL_ROOT_PASS" |debconf-set-selections
  echo "phpmyadmin phpmyadmin/app-password-confirm password $MYSQL_ROOT_PASS" | debconf-set-selections

  aptitude install -y phpmyadmin >> lamp-install.log
 fi
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf >> lamp-install.log
sudo a2enconf phpmyadmin.conf >> lamp-install.log
service apache2 restart >> lamp-install.log

a2enmod ssl
echo " "
echo " "
echo " "
echo "==================================================="
echo "Installation completed! (LAMPP Method)"
echo "Lokasi folder HTML -> /var/www/html/"
echo "PhpMyAdmin is located at http://YOUR_SERVER_IP/phpmyadmin"
echo "Install log is located in lamp-install.log"
echo "==================================================="
echo "MariaDB (MySQL) password: $MYSQL_ROOT_PASS"
echo "PhpMyAdmin username: phpmyadmin"
echo "PhpMyAdmin password: $MYSQL_ROOT_PASS"
echo "==================================================="
}


lempp () {
echo "Installing LEMP stack"
echo " "
read -p "Please enter the desired MySQL root password: " -s MYSQL_ROOT_PASS
echo " "
echo "Installing NGINX"
apt-get install nginx -y >> lemp-install.log

echo " "
echo "Installing MariaDB (MySQL)"
apt-get install mariadb-server -y >> lemp-install.log
apt-get install mariadb-client -y >> lemp-install.log
[ ! -e /usr/bin/expect ]
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none): \"
send \"n\r\"
expect \"Change the root password? \[Y/n\] \"
send \"y\r\"
expect \"New password: \"
send \"$MYSQL_ROOT_PASS\r\"
expect \"Re-enter new password: \"
send \"$MYSQL_ROOT_PASS\r\"
expect \"Remove anonymous users? \[Y/n\] \"
send \"y\r\"
expect \"Disallow root login remotely? \[Y/n\] \"
send \"y\r\"
expect \"Remove test database and access to it? \[Y/n\] \"
send \"y\r\"
expect \"Reload privilege tables now? \[Y/n\] \"
send \"y\r\"
expect eof
")

echo " "
echo "Installing PHP"
apt-get install -y php php-mysql php-redis php-zip -y >> lemp-install.log

echo " "
echo "Installing PhpMyAdmin"
if [ ! -f /etc/phpmyadmin/config.inc.php ];
then
# MYSQL_ROOT_PASS='1234567890'

  echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_ROOT_PASS" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL_ROOT_PASS" |debconf-set-selections
  echo "phpmyadmin phpmyadmin/app-password-confirm password $MYSQL_ROOT_PASS" | debconf-set-selections

  apt-get install phpmyadmin -y >> lemp-install.log
 fi
sudo service nginx restart >> lemp-install.log

echo " "
echo " "
echo " "
echo "==================================================="
echo "Installasi selesai! (LEMPP Method)"
echo "Lokasi folder HTML /var/www/html/"
echo "Lokasi PhpMyAdmin at http://YOUR_SERVER_IP/phpmyadmin"
echo "Silahkan reboot terlebih dahulu"
echo "Log install ada di lokasi lemp-install.log"
echo ""
echo "==================================================="
echo "MariaDB (MySQL) password: $MYSQL_ROOT_PASS"
echo "PhpMyAdmin username: phpmyadmin"
echo "PhpMyAdmin password: $MYSQL_ROOT_PASS"
echo "==================================================="
}


apache2 () {
echo "Memulai Install Apache2"
apt-get install apache2 -y >> apache2-install.log
echo " "
echo " "
echo "==================================================="
echo "Apache2 Terinstall"
echo "Lokasi HTML Folder /var/www/html"
echo "==================================================="
}

nginx () {
echo " Memulai Install NGINX"
apt-get install -y nginx >> nginx-install.log
echo " "
echo " "
echo "==================================================="
echo " NGINX Terinstall "
echo " Lokasi HTML Folder /var/www/html "
echo "==================================================="
}

mysql () {
echo "Memualai Install MariaDB (MySQL)"
echo " "
read -p "Silahkan masukan password root untuk mysql: " -s MYSQL_ROOT_PASS
apt-get install -y mariadb-server >> mysql-install.log
apt-get install -y mariadb-client >> mysql-install.log
[ ! -e /usr/bin/expect ]
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none): \"
send \"n\r\"
expect \"Change the root password? \[Y/n\] \"
send \"y\r\"
expect \"New password: \"
send \"$MYSQL_ROOT_PASS\r\"
expect \"Re-enter new password: \"
send \"$MYSQL_ROOT_PASS\r\"
expect \"Remove anonymous users? \[Y/n\] \"
send \"y\r\"
expect \"Disallow root login remotely? \[Y/n\] \"
send \"y\r\"
expect \"Remove test database and access to it? \[Y/n\] \"
send \"y\r\"
expect \"Reload privilege tables now? \[Y/n\] \"
send \"y\r\"
expect eof
")
echo " "
echo " "
echo "==================================================="
echo "MySQL Terinstall"
echo "==================================================="
}

phpmyadmin () {
echo "Menginstall PhpMyAdmin"
echo " "
read -p "Silahkan masukan MySQL root password: " -s PHPMYADMIN_MYSQL_ROOT_PASS
if [ ! -f /etc/phpmyadmin/config.inc.php ];
then

  echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/admin-pass password $PHPMYADMIN_MYSQL_ROOT_PASS" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_MYSQL_ROOT_PASS" |debconf-set-selections
  echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_MYSQL_ROOT_PASS" | debconf-set-selections

  apt-get install -y phpmyadmin >> phpmyadmin-install.log
 fi
echo " "
echo " "
echo "==================================================="
echo "PhpMyAdmin Terinstall"
echo "==================================================="
}

ssl () {
echo "Running SSL Script"
apt-get install -y certbot pytho3-certbot-apache python3-certbot-nginx >> ssl-install.log
echo " "
read -p "Silahkan masukan domain kamu: " SYS_DOMAIN
SERVER_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
DOMAIN_RECORD=$(dig +short ${SYS_DOMAIN})
if [ "${SERVER_IP}" != "${DOMAIN_RECORD}" ]; then
  echo -e "\e[31m===================================================\e[0m"
  echo -e "\e[31mDomain yang kamu masukan tidak sesuai dengan IP Public Server ini.\e[0m"
  echo -e "\e[31mSialahkan membuat A Reocrd dan pointing ke IP server ini\e[0m"
  echo -e "\e[31mSilahkan ulangi script ini!\e[0m"
  echo -e "\e[31m===================================================\e[0m"
  exit
else
  echo -e "\e[32m===================================================\e[0m"
  echo -e "\e[32mProses domain telah selesai.\e[0m"
  echo -e "\e[32====================================================\e[0m"
  certbot certonly -d $SYS_DOMAIN
fi
echo " "
echo " "
echo " "
echo "==================================================="
echo "Script SSL Selesai Terinstall"
echo "==================================================="
}


echo " "
echo "###################################################"
echo "WebServer installer script by Anggaditya"
echo "Starting install in 3 seconds..."
echo "###################################################"
sleep 3;
clear
sleep 1;
echo " "
echo "========================================================"
echo "       _ _ _ _                 _           _        _ _ "
echo "      (_) (_) |               (_)         | |      | | |"
echo " _ __  _| |_| |__   __ _ _ __  _ _ __  ___| |_ __ _| | |"
echo "| '_ \| | | | '_ \ / _' | '_ \| | '_ \/ __| __/ _' | | |"
echo "| |_) | | | | | | | (_| | | | | | | | \__ \ || (_| | | |"
echo "| .__/|_|_|_|_| |_|\__,_|_| |_|_|_| |_|___/\__\__,_|_|_|"
echo "| |                                                     "
echo "|_|                                                     "
echo " "
echo " "
echo "Stack options:"
echo "1 - Install LAMPP Stack (Linux, Apache, MySQL, PHP + PhpMyAdmin)"
echo "2 - Install LEMPP Stack (Linux, NGINX, MySQL, PHP + PhpMyAdmin)"
echo " "
echo "Individual options:"
echo "3 - Install Apache2"
echo "4 - Install NGINX"
echo "5 - Install MySQL"
echo "6 - Install PhpMyAdmin"
echo "7 - Run SSL Script"
echo " "
echo " Masukan pilihan yang ingin dijalankan ( misal : 1 )"
echo "========================================================"
echo " "
read -p "Silahkan masukan pilihan : " MAINSELECTION
echo " "

if [[ $MAINSELECTION = "1" ]]
then
    lampp
fi

if [[ $MAINSELECTION = "2" ]]
then
    lempp
fi

if [[ $MAINSELECTION = "3" ]]
then
    apache2
fi

if [[ $MAINSELECTION = "4" ]]
then
    nginx
fi

if [[ $MAINSELECTION = "5" ]]
then
    mysql
fi

if [[ $MAINSELECTION = "6" ]]
then
    phpmyadmin
fi

if [[ $MAINSELECTION = "7" ]]
then
    ssl
fi

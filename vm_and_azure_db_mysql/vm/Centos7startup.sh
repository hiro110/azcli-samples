#!/bin/bash

# CentOS7の初期設定を実行
#
# *　変数定義
# *　SELinux無効
# *　システムクロック、ハードウェアクロックのタイムゾーンを変更
# *　キーボードレイアウト変更
# *　ユーザ作成
# *　historyに実行時刻を付与
# *　スワップファイル作成
# *　ntpサーバ変更
# *　sshdコンフィグ修正
# *　パッケージインストール
# *　自動起動設定
# *　コンフィグ作成
# *　プロジェクトディレクトリ作成
# *　ダミーindexファイル作成
# *　シンボリックリンク
# 

#
# 変数を設定すること！
#

# 変数定義

# 案件名
PJ_NAME="myProject"

# VM管理者アカウント
VM_ADMIN_NAME="administrator"

# Azure DB MySQL関連
# DBインスタンス名
DBSERVER_NAME="${PJ_NAME}peadm01"
# DB管理者アカウント
MYSQL_ADMIN_NAME="dbmaster"
MYSQL_ADMIN_PASS="password"
# DB名情報
PROD_DB="proddb"
PRODDB_USER="prod"
PRODDB_PASS="your password"
TEST_DB="testdb"
TESTDB_USER="test"
TESTDB_PASS="your password"

# サーバ設定情報
# ホスト名
PROD_HOST="example.com"
TEST_HOST="test.example.com"
# 開発者アカウント
DEVELOPER_NAME="developer"
# Basic認証情報
BASIC_AUTH_ID="test"
BASIC_AUTH_PASS="test"


# SELinux無効
sudo setenforce 0
sudo cp -p /etc/selinux/config /etc/selinux/config.`date "+%Y%m%d_%H%M%S"`
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# システムクロック、ハードウェアクロックのタイムゾーンを変更
sudo timedatectl set-timezone Asia/Tokyo
sudo timedatectl set-local-rtc 0

# キーボードレイアウト変更
sudo localectl set-locale LANG=ja_JP.utf8
sudo localectl set-keymap jp106

# ユーザ作成
sudo useradd ${DEVELOPER_NAME}

# historyに実行時刻を付与
sudo cp -p /home/${VM_ADMIN_NAME}/.bashrc /home/${VM_ADMIN_NAME}/.bashrc.org
sudo sed -i "$ a # show timestamp\nHISTTIMEFORMAT='%Y-%m-%d %T%z '" /home/${VM_ADMIN_NAME}/.bashrc
sudo cp -p /home/${DEVELOPER_NAME}/.bashrc /home/${DEVELOPER_NAME}/.bashrc.org
sudo sed -i "$ a # show timestamp\nHISTTIMEFORMAT='%Y-%m-%d %T%z '" /home/${DEVELOPER_NAME}/.bashrc

#　スワップファイル作成
sudo cp -p /etc/waagent.conf /etc/waagent.conf.`date "+%Y%m%d_%H%M%S"`
sudo sed -i 's/ResourceDisk.EnableSwap=n/ResourceDisk.EnableSwap=y/' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.SwapSizeMB=0/ResourceDisk.SwapSizeMB=7168/' /etc/waagent.conf

# ntpサーバ変更
## コメントアウト
sudo cp -p /etc/chrony.conf /etc/chrony.conf.`date "+%Y%m%d_%H%M%S"`
sudo sed -i -e "s/server 0.centos.pool.ntp.org iburst/#server 0.centos.pool.ntp.org iburst/g" /etc/chrony.conf
sudo sed -i -e "s/server 1.centos.pool.ntp.org iburst/#server 1.centos.pool.ntp.org iburst/g" /etc/chrony.conf
sudo sed -i -e "s/server 2.centos.pool.ntp.org iburst/#server 2.centos.pool.ntp.org iburst/g" /etc/chrony.conf
sudo sed -i -e "s/server 3.centos.pool.ntp.org iburst/#server 3.centos.pool.ntp.org iburst/g" /etc/chrony.conf
## NTP POOL PROJECTのサーバに矛先変更
sudo sed -i '1s/^/server 3.jp.pool.ntp.org iburst\n/' /etc/chrony.conf
sudo sed -i '1s/^/server 2.jp.pool.ntp.org iburst\n/' /etc/chrony.conf
sudo sed -i '1s/^/server 1.jp.pool.ntp.org iburst\n/' /etc/chrony.conf
sudo sed -i '1s/^/server 0.jp.pool.ntp.org iburst\n/' /etc/chrony.conf
sudo sed -i '1s/^/# NTP POOL PROJECT\n/' /etc/chrony.conf

# sshdコンフィグ修正
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.org
sudo sed -i -e 's/#Port 22/Port 10022/g' /etc/ssh/sshd_config
sudo sed -i -e 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config

# -----WEBサーバ関連-----
# パッケージインストール
sudo yum -y install httpd mod_ssl openssl git epel-release
sudo yum -y install php php-devel php-mbstring php-pdo php-gd php-xml php-mcrypt php-dba php-mysql php-odbc php-pdo php-pear
#sudo yum -y install php php-devel

#sudo cd /etc/yum.repos.d
#sudo curl -O http://rpms.famillecollet.com/enterprise/remi.repo
#sudo yum -y install --enablerepo=remi,remi-php56 \
#  php \
#  php-devel \
#  php-mbstring \
#  php-pdo \
#  php-gd \
#  php-xml \
#  php-mcrypt \
#  php-dba \
#  php-mysql \
#  php-odbc \
#  php-pdo \
#  php-pear

# MySQLクライアントインストール
sudo yum -y localinstall https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
sudo yum -y install mysql-community-client

# 自動起動設定
sudo systemctl enable httpd.service

# コンフィグ作成
## セキュリティ関連
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.org
#sudo sed -i -e "s/#ServerName www.example.com:80/ServerName ${PROD_HOST}:80/g" /etc/httpd/conf/httpd.conf

#sudo sed -i -e "s/    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"/S#    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"/g" /etc/httpd/conf/httpd.conf
#sudo sed -i -e "s/<Directory "/var/www/cgi-bin">/S#<Directory "/var/www/cgi-bin">/g" /etc/httpd/conf/httpd.conf
#sudo sed -i -e "s/    AllowOverride None/S#    AllowOverride None/g" /etc/httpd/conf/httpd.conf
#sudo sed -i -e "s/    Options None/S#    Options None/g" /etc/httpd/conf/httpd.conf
#sudo sed -i -e "s/    Require all granted/S#    Require all granted/g" /etc/httpd/conf/httpd.conf
#sudo sed -i -e "s/</Directory>/S#</Directory>/g" /etc/httpd/conf/httpd.conf

sudo cat << EOF > /etc/httpd/conf.d/security.conf
# Version Info Hiding
ServerTokens Prod
Header unset Server
Header always unset X-Powered-By

# httpoxy
RequestHeader unset Proxy

# Click Jacking Control
Header always append X-Frame-Options SAMEORIGIN

# XSS Control
Header always set X-XSS-Protection "1; mode=block"
Header set X-Content-Type-Options nosniff

# XST Control
TraceEnable Off
EOF

## 本番環境
sudo cat << EOF > /etc/httpd/conf.d/${PROD_HOST}.conf
<VirtualHost *:80>
    ServerName ${PROD_HOST}
    DirectoryIndex index.html index.htm index.php
    DocumentRoot /home/www/${PROD_HOST}/contents/htdocs

    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\"" combined_with_realip
    CustomLog "|/usr/sbin/rotatelogs /home/www/${PROD_HOST}/logs/access_%Y%m%d.log 86400 540" combined
    ErrorLog "|/usr/sbin/rotatelogs /home/www/${PROD_HOST}/logs/error_%Y%m%d.log 86400 540"
    <Directory /home/www/${PROD_HOST}/contents/htdocs>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
        Require method GET POST
    </Directory>

#    RewriteEngine on
#    RewriteCond %{HTTP_HOST} ^${PROD_HOST}$ [nc]
#    RewriteRule ^/(.*) https://${PROD_HOST}/$1 [R=301,L]
</VirtualHost>
<VirtualHost *:80>
    ServerName www.${PROD_HOST}
    RewriteEngine on
    RewriteCond %{HTTP_HOST} ^www.${PROD_HOST}$ [nc]
    RewriteRule ^/(.*) http://${PROD_HOST}/$1 [R=301,L]
#    RewriteRule ^/(.*) https://${PROD_HOST}/$1 [R=301,L]
</VirtualHost>

#<VirtualHost *:443>
#    ServerName ${PROD_HOST}
#    DirectoryIndex index.html index.htm index.php
#    DocumentRoot /home/www/${PROD_HOST}/contents/htdocs
#
#    SSLEngine on
#    SSLCertificateChainFile /home/www/${PROD_HOST}/etc/cert/ca.crt
#    SSLCertificateFile /home/www/${PROD_HOST}/etc/cert/server.crt
#    SSLCertificateKeyFile /home/www/${PROD_HOST}/etc/cert/server.key
#    SSLProtocol all -SSLv2 -SSLv3 -TLSv1
#    SSLHonorCipherOrder ON
#    SSLCipherSuite  ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
#
#    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\"" combined_with_realip
#    CustomLog "|/usr/sbin/rotatelogs /home/www/${PROD_HOST}/logs/access_%Y%m%d.log 86400 540" combined
#    ErrorLog "|/usr/sbin/rotatelogs /home/www/${PROD_HOST}/logs/error_%Y%m%d.log 86400 540"
#
#    <Directory /home/www/${PROD_HOST}/contents/htdocs>
#        Options -Indexes +FollowSymLinks +MultiViews
#        AllowOverride All
#        Require all granted
#        Require method GET POST
#    </Directory>
#</VirtualHost>
#<VirtualHost *:443>
#    ServerName www.${PROD_HOST}
#    RewriteEngine on
#    RewriteCond %{HTTP_HOST} ^www.${PROD_HOST}$ [nc]
#    RewriteRule ^/(.*) https://${PROD_HOST}/$1 [R=301,L]
#</VirtualHost>
EOF

## テスト環境
sudo cat << EOF > /etc/httpd/conf.d/${TEST_HOST}.conf
<VirtualHost *:80>
    ServerName ${TEST_HOST}
    DirectoryIndex index.html index.htm index.php
    DocumentRoot /home/www/${TEST_HOST}/contents/htdocs

    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\"" combined_with_realip
    CustomLog "|/usr/sbin/rotatelogs /home/www/${TEST_HOST}/logs/access_%Y%m%d.log 86400 540" combined
    ErrorLog "|/usr/sbin/rotatelogs /home/www/${TEST_HOST}/logs/error_%Y%m%d.log 86400 540"
    <Directory /home/www/${TEST_HOST}/contents/htdocs>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
        Require method GET POST
    </Directory>

#    RewriteEngine on
#    RewriteCond %{HTTP_HOST} ^${TEST_HOST}$ [nc]
#    RewriteRule ^/(.*) https://${TEST_HOST}/$1 [R=301,L]
</VirtualHost>

#<VirtualHost *:443>
#    DirectoryIndex index.html index.htm index.php
#    DocumentRoot /home/www/${TEST_HOST}/contents/htdocs
#    ServerName ${TEST_HOST}
#
#    SSLEngine on
#    SSLCertificateChainFile /home/www/${TEST_HOST}/etc/cert/ca.crt
#    SSLCertificateFile /home/www/${TEST_HOST}/etc/cert/server.crt
#    SSLCertificateKeyFile /home/www/${TEST_HOST}/etc/cert/server.key
#    SSLProtocol all -SSLv2 -SSLv3 -TLSv1
#    SSLHonorCipherOrder ON
#    SSLCipherSuite  ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
#
#    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\"" combined_with_realip
#    CustomLog "|/usr/sbin/rotatelogs /home/www/${TEST_HOST}/logs/access_%Y%m%d.log 86400 540" combined
#    ErrorLog "|/usr/sbin/rotatelogs /home/www/${TEST_HOST}/logs/error_%Y%m%d.log 86400 540"
#
#    <Directory /home/www/${TEST_HOST}/contents/htdocs>
#        Options -Indexes +FollowSymLinks +MultiViews
#        AllowOverride All
#        Require all granted
#        Require method GET POST
#    </Directory>
#</VirtualHost>
EOF

sudo chown root:root /etc/httpd/conf.d/security.conf
sudo chown root:root /etc/httpd/conf.d/${PROD_HOST}.conf
sudo chown root:root /etc/httpd/conf.d/${TEST_HOST}.conf
sudo mv /etc/httpd/conf.d/autoindex.conf /etc/httpd/conf.d/autoindex.conf.bk
sudo mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.bk

# プロジェクトディレクトリ作成
sudo mkdir -pm 755 /home/www/${PROD_HOST}/contents/htdocs
sudo mkdir -pm 755 /home/www/${PROD_HOST}/logs
sudo mkdir -pm 755 /home/www/${PROD_HOST}/data
sudo mkdir -pm 755 /home/www/${PROD_HOST}/etc
sudo mkdir -pm 755 /home/www/${PROD_HOST}/contents/htdocs/.well-known/pki-validation/
sudo mkdir -pm 755 /home/www/${PROD_HOST}/etc/cert
sudo mkdir -pm 755 /home/www/${TEST_HOST}/contents/htdocs
sudo mkdir -pm 755 /home/www/${TEST_HOST}/logs
sudo mkdir -pm 755 /home/www/${TEST_HOST}/data
sudo mkdir -pm 755 /home/www/${TEST_HOST}/etc
sudo mkdir -pm 755 /home/www/${TEST_HOST}/etc/cert
sudo mkdir -pm 755 /home/www/${TEST_HOST}/contents/htdocs/.well-known/pki-validation/
# ダミーファイル作成
sudo echo "${PROD_HOST}" > /home/www/${PROD_HOST}/contents/htdocs/index.html
sudo echo "${TEST_HOST}" > /home/www/${TEST_HOST}/contents/htdocs/index.html
#sudo chown -R ${DEVELOPER_NAME}:${DEVELOPER_NAME}　/home/www/${PROD_HOST}
#sudo chown -R ${DEVELOPER_NAME}:${DEVELOPER_NAME}　/home/www/${TEST_HOST}
sudo touch /home/www/${PROD_HOST}/contents/htdocs/.well-known/pki-validation/godaddy.html
sudo touch /home/www/${TEST_HOST}/contents/htdocs/.well-known/pki-validation/godaddy.html
# シンボリックリンク
sudo ln -s /etc/httpd/conf.d/${PROD_HOST}.conf /home/www/${PROD_HOST}/etc/${PROD_HOST}.conf
sudo ln -s /etc/httpd/conf.d/${TEST_HOST}.conf /home/www/${TEST_HOST}/etc/${TEST_HOST}.conf

# Basic認証設定（テスト環境のみ）
sudo htpasswd -c -b /home/www/${TEST_HOST}/etc/.htpasswd $BASIC_AUTH_ID $BASIC_AUTH_ID
sudo cat << EOF > /home/www/${TEST_HOST}/contents/htdocs/.htaccess
AuthUserfile /home/www/${TEST_HOST}/etc/.htpasswd
AuthGroupfile /dev/null
AuthName "Please enter your ID and password"
AuthType Basic
require valid-user
EOF
#sudo chown ${DEVELOPER_NAME}:${DEVELOPER_NAME}　/home/www/${TEST_HOST}/contents/htdocs/.htaccess

# PHP初期設定
sudo cp /etc/php.ini /etc/php.ini.org
sudo sed -i -e 's/;mbstring.language = Japanese/mbstring.language = Japanese/g' /etc/php.ini
sudo sed -i -e 's/;mbstring.internal_encoding =/mbstring.encoding_translation = Off/g' /etc/php.ini
sudo sed -i -e 's/;mbstring.encoding_translation = Off/mbstring.encoding_translation = Off/g' /etc/php.ini
sudo sed -i -e 's/;mbstring.http_input =/mbstring.http_input = pass/g' /etc/php.ini
sudo sed -i -e 's/;mbstring.http_output =/mbstring.http_output = pass/g' /etc/php.ini
sudo sed -i -e 's/;mbstring.detect_order = auto/mbstring.detect_order = auto/g' /etc/php.ini
sudo sed -i -e 's/expose_php = On/expose_php = Off/g' /etc/php.ini
sudo sed -i -e 's/session.hash_function = 0/session.hash_function = 1/g' /etc/php.ini

# ユーザ作成
#mysql -h ${DBSERVER_NAME}.mysql.database.azure.com -u ${MYSQL_ADMIN_NAME}@${DBSERVER_NAME} -p${MYSQL_ADMIN_PASS} -e "CREATE USER ${PRODDB_USER} identified by '${PRODDB_PASS}', ${TESTDB_USER} identified by '${TESTDB_PASS}';"
# 権限追加
#mysql -h ${DBSERVER_NAME}.mysql.database.azure.com -u ${MYSQL_ADMIN_NAME}@${DBSERVER_NAME} -p${MYSQL_ADMIN_PASS} -e "grant all on ${PROD_DB}.* to ${PRODDB_USER} identified by '${PRODDB_PASS}';"
#mysql -h ${DBSERVER_NAME}.mysql.database.azure.com -u ${MYSQL_ADMIN_NAME}@${DBSERVER_NAME} -p${MYSQL_ADMIN_PASS} -e "grant all on ${TEST_DB}.* to ${TESTDB_USER} identified by '${TESTDB_PASS}';"
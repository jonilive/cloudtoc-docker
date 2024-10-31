FROM ubuntu:24.04

EXPOSE 80 443

# Essentials
RUN echo "Europe/Lisbon" > /etc/timezone
RUN apt update && apt install -y \
    sudo nano openssl git cron apache2 \
    php php-common php-pear php-cli php-curl \
    php-dev php-gd php-igbinary php-imagick \
    php-imap php-intl php-mbstring php-mysql \
    php-opcache php-readline php-redis \
    php-soap php-sqlite3 php-xml php-xmlrpc \
    php-zip libapache2-mod-php \
    htop python3 python3-pip \
	default-jdk

# Install python3 dependencies using pip
RUN find /usr/lib/python* -type f -name "EXTERNALLY-MANAGED" -exec rm -f {} \;
RUN pip install numpy zxing-cpp PyMuPDF Pillow

# Updating default shell to bash
RUN ln -sf /bin/bash /bin/sh

RUN userdel -f -r ubuntu
RUN useradd -u 1000 -d /cloudtoc -m cloudtoc
RUN usermod -aG sudo cloudtoc
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY apache2.conf /etc/apache2/apache2.conf
COPY sites-enabled/ /etc/apache2/sites-enabled/
COPY index.html /var/www/html/index.html
COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

# enable apache ssl module
RUN a2enmod remoteip
RUN a2enmod ssl
RUN a2enmod rewrite

RUN mkdir -p /etc/ssl/apache2
RUN echo "basicConstraints = CA:FALSE" >> /etc/ssl/openssl.cnf
RUN openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout /etc/ssl/apache2/cloudtoc.pt.key -out /etc/ssl/apache2/cloudtoc.pt.pem \
    -days 365 -subj "/C=PT/O=Cloudtoc/CN=cloudtoc.pt"
RUN openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout /etc/ssl/apache2/cloudtoc.net.key -out /etc/ssl/apache2/cloudtoc.net.pem \
    -days 365 -subj "/C=PT/O=Cloudtoc/CN=cloudtoc.net"

# Copy certificates from /ssl if they exist
COPY ssl/ /etc/ssl/apache2/

# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# Volumes configuration
RUN mkdir -p /cloudtoc/storage
RUN mkdir -p /cloudtoc/envs
VOLUME /cloudtoc/storage
VOLUME /cloudtoc/envs
RUN ln -sf /cloudtoc/storage/logs/access.log /var/log/apache2/access.log
RUN ln -sf /cloudtoc/storage/logs/error.log /var/log/apache2/error.log

# Creating crontab
RUN echo '* * * * * cd /cloudtoc && php artisan schedule:run >> /dev/null 2>&1' | crontab -u cloudtoc -


USER cloudtoc
WORKDIR /cloudtoc

ENTRYPOINT ["/entrypoint.sh"]
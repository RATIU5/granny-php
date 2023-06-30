# FROM dynaum/php-apache-composer:latest

FROM alpine:3.17

WORKDIR /

RUN apk --no-cache update && apk upgrade

RUN apk --no-cache --update --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    add apache2 \
    apache2-ssl \
	git \
    curl \
	g++ \
	make \
    php82 \
	php82-pear \
	php82-dev \
    php82-apache2 \
    php82-bcmath \
    php82-bz2 \
    php82-calendar \
    php82-common \
    php82-ctype \
    php82-curl \
    php82-dom \
    php82-gd \
    php82-pdo \
    php82-iconv \
	php82-json \
    php82-mbstring \
    php82-mysqli \
    php82-mysqlnd \
    php82-openssl \
    php82-pdo_mysql \
    php82-phar \
    php82-session \
	php82-xdebug \
    php82-pecl-xdebug \
    php82-xml \
    php82-zip \
    php82-xmlreader \
    php82-simplexml \
    php82-tokenizer \
    php82-xmlwriter

RUN mv /usr/bin/php82 /usr/bin/php && \
    chmod +x /usr/bin/php

# Add composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

HEALTHCHECK CMD wget -q --no-cache --spider localhost

# Setup Granny Dashboard
RUN git clone -b main https://github.com/RATIU5/granny-dashboard.git /htdocs/
RUN rm -f version.json
RUN rm -rf .git
RUN mv /htdocs/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh
RUN rm -rf /htdocs/phpmyadmin

# Setup phpMyAdmin
RUN mkdir /htdocs/phpmyadmin
WORKDIR /htdocs
RUN composer create-project phpmyadmin/phpmyadmin
RUN echo "<?php \
# The host must match the name given to mysql on the docker-compose.yml file
\$cfg['Servers'][1]['host'] = 'mariadb'; \
\$cfg['Servers'][1]['compress'] = false; \
\$cfg['Servers'][1]['AllowNoPassword'] = true; \
\$cfg['blowfish_secret'] = 'my_super_secret_phrase'; \
?>" > /htdocs/phpmyadmin/config.inc.php


# Fix error on WSL2
RUN echo "Mutex posixsem" >> /etc/apache2/apache2.conf

# Cleanup
RUN rm -rf /var/cache/apk/*

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]

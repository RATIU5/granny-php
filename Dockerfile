# FROM dynaum/php-apache-composer:latest

FROM alpine:3.17

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
    php82-xml

RUN mv /usr/bin/php82 /usr/bin/php && \
    chmod +x /usr/bin/php

# Add composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer


EXPOSE 80 443

HEALTHCHECK CMD wget -q --no-cache --spider localhost

# Setup Granny Dashboard
WORKDIR /
ADD https://api.github.com/repos/RATIU5/granny-dashboard/git/refs/heads/main version.json
RUN git clone -b main https://github.com/RATIU5/granny-dashboard.git /htdocs/
RUN rm -f version.json
RUN rm -rf .git
RUN mv /htdocs/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh
WORKDIR /htdocs

# Fix error on WSL2
RUN echo "Mutex posixsem" >> /etc/apache2/apache2.conf

ENTRYPOINT ["/docker-entrypoint.sh"]

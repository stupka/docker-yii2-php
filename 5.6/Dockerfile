FROM sergeymakinen/yii2-php:base

MAINTAINER Igor Stupka

# apache2
RUN apt-get update && apt-get install -y --no-install-recommends \
		apache2 \
		software-properties-common \
		supervisor \
	&& apt-get clean \
	&& rm -fr /var/lib/apt/lists/*

# Generate snakeoil SSL certificates on Debian

RUN apt-get update && apt-get install ssl-cert && make-ssl-cert generate-default-snakeoil && usermod --append --groups ssl-cert root \
	&& ls -l /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/private/ssl-cert-snakeoil.key


# PHP 5.6
RUN apt-get update && apt-get install -y --no-install-recommends \
                libapache2-mod-php5.6 \
                php5.6 \
                php5.6-cli \
                php5.6-curl \
                php5.6-dev \
                php5.6-gd \
                php5.6-imap \
                php5.6-intl \
                php5.6-mbstring \
                php5.6-mcrypt \
                php5.6-mysql \
                php5.6-pgsql \
                php5.6-pspell \
                php5.6-xml \
                php5.6-xmlrpc \
                php-apcu \
                php-memcached \
                php-pear \
                php-redis \
        && apt-get clean \
        && rm -fr /var/lib/apt/lists/*

# OCI
#RUN apt-get update && apt-get install -y build-essential php-pear php5.6-dev curl  
RUN apt-get update && apt-get install -y make php-pear php5.6-dev curl \ 
    && pecl channel-update pecl.php.net \
    && mkdir $ORACLE_HOME/lib/sdk && ln -s $ORACLE/include/oracle/$ORACLE_INSTANTCLIENT_MAJOR/client64 $ORACLE_HOME/lib/sdk/include \
    && echo "instantclient,$ORACLE_HOME/lib" | pecl install oci8-2.0.12 \
    && rm -rf $ORACLE_HOME/lib/sdk \
    && TMP_DIR="$(mktemp -d)" && cd "$TMP_DIR" && curl -L https://pecl.php.net/get/PDO_OCI-1.0.tgz | tar ixz && cd PDO_OCI-1.0 \
    && sed -i "s#libclntsh.\$SHLIB_SUFFIX_NAME.10.1#libclntsh.\$SHLIB_SUFFIX_NAME.$ORACLE_INSTANTCLIENT_MAJOR#g" config.m4 \
    && sed -i "s#PDO_OCI_VERSION=10.1#PDO_OCI_VERSION=$ORACLE_INSTANTCLIENT_MAJOR#g" config.m4 \
    && sed -i "s#10.2)#$ORACLE_INSTANTCLIENT_MAJOR)#g" config.m4 \
    && phpize \
    && sed -i 's#$prefix/include/php/ext#/usr/include/php/20131226/ext#g' configure \
    && ./configure \
    && sed -i 's#function_entry pdo_oci_functions#zend_function_entry pdo_oci_functions#g' pdo_oci.c \
    && make \
    && mv modules/pdo_oci.so /usr/lib/php/20131226 \
    && echo 'extension=/usr/lib/php/20131226/oci8.so' > /etc/php/5.6/mods-available/oci8.ini \
    && echo 'extension=/usr/lib/php/20131226/pdo_oci.so' > /etc/php/5.6/mods-available/pdo_oci.ini \
    && phpenmod oci8 pdo_oci \
    && rm -rf "$TMP_DIR" \
    && rm -rf /var/lib/apt/lists/* && apt-get purge -y --auto-remove php-pear php5.6-dev curl


RUN apt-get update && apt-get install -y mc \
        && apt-get clean \
        && rm -fr /var/lib/apt/lists/*

COPY  etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN ln -r -s /etc/apache2/mods-available/ssl.load  /etc/apache2/mods-enabled/ssl.load
COPY  etc/apache2/sites-enabled/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf

RUN ln -r -s /etc/apache2/mods-available/rewrite.load  /etc/apache2/mods-enabled/rewrite.load

COPY etc/php5/apache2/conf.d/20-xdebug.ini /etc/php5/apache2/conf.d/20-xdebug.ini
RUN rm -f /etc/php5/apache2/conf.d/php.ini

RUN echo "# Oracle enviroment variables" >>  /etc/apache2/envvars && \ 
    echo "export NLS_DATE_FORMAT=DD.MM.YYYY" >>  /etc/apache2/envvars && \ 
    echo "export NLS_LANG=AMERICAN_AMERICA.AL32UTF8" >> /etc/apache2/envvars && \ 
    echo "export NLS_SORT=German" >> /etc/apache2/envvars

RUN a2enmod rewrite

RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY run.sh /run.sh
RUN chmod 755 /run.sh

EXPOSE 80
WORKDIR /app

CMD ["/run.sh"]

FROM php:5.6-apache

# install the PHP extensions we need
RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y \
		libjpeg-dev \
		libpng12-dev \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mysqli opcache
# TODO consider removing the *-dev deps and only keeping the necessary lib* packages

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
RUN touch /usr/local/etc/php/conf.d/uploads.ini
RUN { \
		echo 'file_uploads = On'; \
		echo 'memory_limit = 64M'; \
		echo 'upload_max_filesize = 64M'; \
		echo 'post_max_size = 64M'; \
		echo 'max_execution_time = 600'; \
	} > /usr/local/etc/php/conf.d/uploads.ini
RUN a2enmod rewrite expires

VOLUME /var/www/html

COPY . /var/www/html/

CMD ["apache2-foreground"]
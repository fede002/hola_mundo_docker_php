# Imagen base de Docker para PHP y Apache
FROM php:8.0-apache

# Copiar los archivos del proyecto Laravel al contenedor
COPY . /var/www/html/

# Instalar las dependencias necesarias para Laravel
RUN apt-get update && \
    apt-get install -y \
        libzip-dev \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm \
        && docker-php-ext-install zip pdo_mysql  -j$(nproc) gd && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Instalar Xdebug
RUN pecl install -o -f xdebug \
    && docker-php-ext-enable xdebug

# Configurar Xdebug
RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=VSCODE" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

#&& echo "xdebug.client_port=9008" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Configurar el servidor Apache para usar el directorio public como la raíz del servidor
RUN sed -i -e 's/html$/html\/public/g' /etc/apache2/sites-available/000-default.conf && \
    a2enmod rewrite

# Configurar el directorio de trabajo
WORKDIR /var/www/html

# Exponer el puerto 80
EXPOSE 80

# Definir el comando de inicio para el contenedor
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
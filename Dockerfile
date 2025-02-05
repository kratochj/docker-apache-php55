# Use Ubuntu as the base image
FROM ubuntu:14.04

# Set environment variables to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt-get update && apt-get install -y \
    apache2 \
    php5 \
    php5-mysql \
    libapache2-mod-php5 \
    curl \
    wget \
    unzip \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add PHP handler for .php files
RUN echo '<FilesMatch "\.php$">\n\
    SetHandler application/x-httpd-php\n\
</FilesMatch>' > /etc/apache2/conf-available/php-handler.conf && \
    a2enconf php-handler

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set up PHP configuration
RUN sed -i "s/;date.timezone =/date.timezone = UTC/" /etc/php5/apache2/php.ini
RUN sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php5/apache2/php.ini

RUN grep -q "^short_open_tag" /etc/php5/apache2/php.ini \
    && sed -i 's/^short_open_tag = .*/short_open_tag = On/' /etc/php5/apache2/php.ini \
    || echo "short_open_tag = On" >> /usr/local/etc/php/conf.d/custom.ini



# Set the working directory
WORKDIR /var/www/html

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]

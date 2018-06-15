FROM amazonlinux:2018.03

# File Author / Maintainer
MAINTAINER ljay

# update amazon software repo
RUN yum -y update && yum -y install shadow-utils

#
# All installed packages via YUM are amazon linux maintained and prepared to run best on amazon-linux distro
#

# install Apache/2.4.x
RUN yum -y install libtool httpd24 httpd24-devel

# install php 7.0.x
RUN yum -y install \
	php70 php70-devel php70-common php70-cli php7-pear php70-json php70-process \
	php70-mcrypt php70-gd php70-bcmath php70-imap php70-intl php70-mbstring \
	php70-mysqlnd php70-pdo php70-pecl-igbinary php70-pecl-imagick \
	php70-pecl-redis php70-soap php70-xml php70-xmlrpc

# custom php.ini
# /etc/php-7.0.conf/php.ini takes precedence of /etc/php.ini (php7 only)
# COPY ./php.ini /etc/php-7.0.conf/php.ini

# cloudflare apache mod
RUN yum -y install wget
RUN wget -O mod_cloudflare.c https://www.cloudflare.com/static/misc/mod_cloudflare/mod_cloudflare.c \
	&& apxs -a -i -c mod_cloudflare.c \
    && apachectl -k restart

# make sure apache starts on boot
RUN chkconfig httpd on && chown -R apache /var/www

# apache rewrite allowed via .htaccess files
RUN sed -i '/<Directory "\/var/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf

# persistent / runtime deps
RUN yum -y update && yum -y install \
	ca-certificates \
	curl \
	libcurl \
	libedit \
	libxml2

RUN rm -rf /var/www/html \
	&& mkdir -p /var/lock/httpd /var/run/httpd /var/log/httpd /var/www/html \
	&& chown -R apache:apache /var/lock/httpd /var/run/httpd /var/log/httpd /var/www/html

# Apache + PHP requires preforking Apache for best results
# not necessary, amazon linux httpd24 has this by default
#RUN find /etc/httpd -name "*.conf" -type f -exec sed -i 's/^LoadModule mpm_event_module/#&/' {} +
#RUN find /etc/httpd -name "*.conf" -type f -exec sed -i 's/^#LoadModule mpm_prefork_module/&/' {} +

# copy bash script to disable unused apache modules
COPY ./apache2-disable-mods.sh /tmp/apache2-disable-mods.sh
RUN chmod +x /tmp/apache2-disable-mods.sh
RUN /tmp/apache2-disable-mods.sh

# cleanup
RUN yum clean all && rm -rf /tmp/* /var/tmp/*

WORKDIR /var/www/html

EXPOSE 80

# Start the httpd service
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
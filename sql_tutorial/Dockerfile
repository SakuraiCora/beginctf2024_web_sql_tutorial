FROM nyr4ki/php_7.4_mysql_8.0:v0
COPY ./ctf.sql /var/ctf.sql
COPY ./secret.sql /var/secret.sql
COPY src /var/www/html
RUN chown -R www-data:www-data /var/www/html
COPY ./start.sh /var/start.sh
RUN chmod +x /var/start.sh
RUN sh -c "echo secure_file_priv=\'\' >>/etc/mysql/mysql.conf.d/mysqld.cnf"
RUN sh -c 'mysqld_safe &' \
    && sleep 5s
WORKDIR /var/www/html
EXPOSE 80
ENTRYPOINT ["sh","/var/start.sh"]
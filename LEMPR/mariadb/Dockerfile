From mariadb:latest

ENV TZ=Asia/Shanghai

COPY db-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/db-entrypoint.sh
ENTRYPOINT ["db-entrypoint.sh"]

COPY my.cnf /etc/mysql/my.cnf
CMD ["mysqld"]



  

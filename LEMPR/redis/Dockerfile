From redis:latest

ENV TZ=Asia/Shanghai

COPY redis-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["redis-entrypoint.sh"]

COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]



  

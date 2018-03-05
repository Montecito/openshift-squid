FROM sameersbn/ubuntu:14.04.20170123
MAINTAINER sameer@damagehead.com

ENV SQUID_VERSION=3.3.8 \
    SQUID_CACHE_DIR=/var/spool/squid3 \
    SQUID_LOG_DIR=/var/log/squid3 \
    SQUID_USER=proxy \
    RUN_USER=500 \
    RUN_GROUP=0

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 80F70E11F0F0D5F10CB20E62F5DA5F09C3173AA6 \
 && echo "deb http://ppa.launchpad.net/brightbox/squid-ssl/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y squid3-ssl=${SQUID_VERSION}* \
 && mv /etc/squid3/squid.conf /etc/squid3/squid.conf.dist \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/squid/ssl_cert \
 && cd /etc/squid/ssl_cert \
 #&& openssl req -new -newkey rsa:1024 -days 1365 -nodes -x509 -keyout myca.pem -out myca.pem \
 && openssl genrsa -des3 -passout pass:x -out server.pass.key 2048 \
 && openssl rsa -passin pass:x -in server.pass.key -out server.key \
 && rm server.pass.key \
 && openssl req -new -key server.key -out server.csr -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=cloud.itandtel.at" \
 && openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt \
 && cd - \
 && chmod -R 775 /etc/squid/ssl_cert

COPY squid.conf /etc/squid3/squid.conf
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

USER ${RUN_USER}:${RUN_GROUP}
EXPOSE 3128 3129
VOLUME ["${SQUID_CACHE_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]

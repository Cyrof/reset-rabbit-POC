FROM alpine:latest

# install postfix and required dependencies 
RUN apk add --no-cache \
	postfix \
	mailx \
	cyrus-sasl \
	ca-certificates \
	&& mkdir -p /var/spool/postfix/ \
	&& touch /etc/postfix/sasl_passwd

# copy entrypoint script 
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# expose postfix port 
EXPOSE 25

# start the entrypoint script 
CMD ["/entrypoint.sh"]

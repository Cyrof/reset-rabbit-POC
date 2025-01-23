#!/bin/sh

# define paths for secrets 
SASL_PASSWD_FILE="/run/secrets/smtp_sasl_passwd"

# Check if the secret exists
if [ ! -f "$SASL_PASSWD_FILE" ]; then
	echo "Error SMTP SASL password file not found!"
	exit 1 
fi

# read the secret and configure Postfix 
SMTP_SASL_PASSWD=$(cat "$SASL_PASSWD_FILE")
echo "$SMTP_SASL_PASSWD" > /etc/postfix/sasl_passwd

# configure postfix main.cf
cat <<EOL >> /etc/postfix/main.cf
mynetworks = 127.0.0.0/8 [::1]/128 172.25.0.0/16
relayhost = [smtp.gmail.com]:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = lmdb:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_use_tls = yes
EOL

# secure the credentials 
postmap /etc/postfix/sasl_passwd
chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.lmdb
chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.lmdb

# start postfix in the foreground 
postfix start-fg

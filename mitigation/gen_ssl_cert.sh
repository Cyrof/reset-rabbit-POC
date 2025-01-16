#! /bin/bash

# This file will generate `server.crt` and `server.key` automatically for nginx

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/reset-rabbit-POC/mitigation/certs/server.key -out ~/reset-rabbit-POC/mitigation/certs/server.crt -subj "/CN=localhost"

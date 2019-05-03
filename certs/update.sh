#!/usr/bin/env bash
openssl req -x509 -nodes -days 2000 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config self-certificate.conf -passin pass:YourSecurePassword
openssl pkcs12 -export -out localhost.pfx -inkey localhost.key -in localhost.crt -passout pass:YourSecurePassword -passin pass:YourSecurePassword
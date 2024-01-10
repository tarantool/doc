#!/usr/bin/env bash
set -xeuo pipefail

# 1. Generate a root CA key.
openssl genrsa -out root_ca.key 2048

# 2. Generate a root CA certificate.
openssl req -x509 -new -key root_ca.key -days 365 -out root_ca.crt -subj "/C=US/CN=Example-Root-CA"

# 3. Generate server keys encrypted using different passphrases.
openssl genrsa -aes256 -passout pass:'qwerty' -out server001.key 2048
openssl genrsa -aes256 -passout pass:'123456' -out server002.key 2048
openssl genrsa -aes256 -passout pass:'topsecret' -out server003.key 2048

# 4. Create certificate signing requests based on server keys.
openssl req -new -key server001.key -passin pass:'qwerty' -subj "/C=US/ST=State/L=City/O=Example-Certificates/CN=server001/" -out server001.csr
openssl req -new -key server002.key -passin pass:'123456' -subj "/C=US/ST=State/L=City/O=Example-Certificates/CN=server002/" -out server002.csr
openssl req -new -key server003.key -passin pass:'topsecret' -subj "/C=US/ST=State/L=City/O=Example-Certificates/CN=server003/" -out server003.csr

# 5. Generate server certificates.
openssl x509 -req -in server001.csr -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1") -days 365 -CA root_ca.crt -CAkey root_ca.key -CAcreateserial -out server001.crt
openssl x509 -req -in server002.csr -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1") -days 365 -CA root_ca.crt -CAkey root_ca.key -CAcreateserial -out server002.crt
openssl x509 -req -in server003.csr -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1") -days 365 -CA root_ca.crt -CAkey root_ca.key -CAcreateserial -out server003.crt

cp server001.crt server001.key instance001
cp server002.crt server002.key instance002
cp server003.crt server003.key instance003

rm -rf root_ca.key server*

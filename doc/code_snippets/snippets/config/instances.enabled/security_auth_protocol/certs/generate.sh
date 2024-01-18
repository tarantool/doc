#!/usr/bin/env bash
set -xeuo pipefail

# 1. Generate an unencrypted server key.
openssl genrsa -out server.key 2048

# 2. Create a certificate signing request based on the server key.
openssl req -new -key server.key -subj "/C=US/ST=State/L=City/O=Example-Certificates/CN=server/" -out server.csr

# 3. Generate a server certificate.
openssl x509 -req -in server.csr -signkey server.key -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1") -days 365 -out server.crt

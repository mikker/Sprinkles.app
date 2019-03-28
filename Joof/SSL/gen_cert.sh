#!/bin/bash
set -e

bundle=$1
container=$2
password=$3

mkdir -p Certs && cd Certs

/usr/bin/openssl genrsa -des3 -passout pass:$password -out rootCA.key 2048
/usr/bin/openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3652 -out rootCA.pem -passin pass:$password -config $bundle/rootCA.csr.conf
/usr/bin/openssl x509 -outform der -in rootCA.pem -out rootCA.der
/usr/bin/openssl req -new -sha256 -nodes -out joof.csr -newkey rsa:2048 -keyout joof.key -config $bundle/joof.csr.conf
/usr/bin/openssl x509 -req -in joof.csr -CA rootCA.pem -CAkey rootCA.key -set_serial 1 -out joof.crt -days 3652 -sha256 -extfile $bundle/v3.ext -passin pass:$password


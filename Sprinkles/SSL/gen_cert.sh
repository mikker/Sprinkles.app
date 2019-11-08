#!/bin/bash
set -e

bundle=$1
container=$2
password=$3

mkdir -p Certs && cd Certs

echo "--- Generate root CA key ------------------------"
/usr/bin/openssl genrsa -des3 \
    -passout pass:$password \
    -out rootCA.key 2048
echo "-------------------------------------------------"

echo "- Generate root CA certificate ------------------"
/usr/bin/openssl req -x509 -new -nodes \
    -key rootCA.key \
    -sha256 -days 825 \
    -out rootCA.pem \
    -passin pass:$password \
    -config $bundle/rootCA.csr.conf
echo "-------------------------------------------------"

echo "- Convert root CA to .der -----------------------"
/usr/bin/openssl x509 \
    -outform der \
    -in rootCA.pem \
    -out rootCA.der
echo "-------------------------------------------------"

echo "- Create localhost key --------------------------"
/usr/bin/openssl req -new -sha256 -nodes \
    -out sprinkles.csr \
    -newkey rsa:2048 \
    -keyout sprinkles.key \
    -config $bundle/sprinkles.csr.conf
echo "-------------------------------------------------"

echo "- Create localhost certificate based on root CA -"
/usr/bin/openssl x509 -req \
    -in sprinkles.csr \
    -CA rootCA.pem -CAkey rootCA.key -CAcreateserial \
    -out sprinkles.crt \
    -days 825 \
    -sha256 -extfile $bundle/v3.ext \
    -passin pass:$password
echo "-------------------------------------------------"

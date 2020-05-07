#!/bin/bash

set -xe

# DANE fields
DANE_USAGE=3
DANE_SELECTION=1
DANE_MATCHING=1

AUTHORITY="mail.katmail.xyz."

# take a PEM file and produce TSLA record
CERT_DIR=""

[ ! -d $CERT_DIR ] && echo "cert dir not found, bailing" && exit 1
cd $CERT_DIR

[ ! -f cert.pem ] && echo "cert.pem not found, bailing" && exit 1
CERT_PKEY_DIGEST=$(openssl x509 -in cert.pem -pubkey -noout | openssl pkey -pubin -outform DER | openssl sha256 | cut -d= -f2 | tr -d " ")

echo "_25.tcp.$AUTHORITY IN TLSA $DANE_USAGE $DANE_SELECTION $DNAME_MATCHING $CERT_PKEY_DIGEST"

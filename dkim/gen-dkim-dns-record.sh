#!/bin/bash

KEYFILE="$(find . -name *.key)"

PUBKEY=$(openssl rsa -in $KEYFILE -pubout 2>/dev/null | tail -n +2 | head -n -1)
echo "v=DKIM1; p=$PUBKEY"

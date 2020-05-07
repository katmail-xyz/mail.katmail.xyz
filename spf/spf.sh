#!/bin/bash


IP4=""
while read -r ip; do
    IP4=$IP4" ip4:$ip"
done<ip4.list

IP6=""
while read -r ip; do
    IP6=$IP6" ip6:$ip"
done<ip6.list

INCLUDE=""
while read -r include; do
    INCLUDE=$INCLUDE" include:$include"
done<include.list

SPF_RECORD="v=spf1 a mx $IP4 $IP6 $INCLUDE -all"

echo $SPF_RECORD

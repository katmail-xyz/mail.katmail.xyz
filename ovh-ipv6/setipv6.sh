#!/bin/bash

set -x

YOUR_IPV6="2402:1f00:8000:800::1813"
IPV6_GATEWAY="2402:1f00:8000:800::1"

case $1 in
    up)
	ip -6 addr add $YOUR_IPV6 dev eth0
	ip -6 route add $IPV6_GATEWAY dev eth0
	ip -6 route add default via $IPV6_GATEWAY dev eth0
	;;
    down)
	ip -6 route del default via $IPV6_GATEWAY dev eth0
	ip -6 route del $IPV6_GATEWAY dev eth0
	ip -6 addr del $YOUR_IPV6 dev eth0
	;;
    *)
        echo "unknown directive"
	exit 1
	;;
esac

exit 0

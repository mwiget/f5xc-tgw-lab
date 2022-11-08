#!/bin/bash
# master_private_ip_address = 10.65.2.30,10.65.6.188,10.65.10.229
# master_public_ip_address = 52.200.63.233,3.217.1.63,34.204.231.23

IPS="52.200.63.233 3.217.1.63 34.204.231.23"
while true; do
  for IP in $IPS; do
    echo -n "`date` $IP "
    curl -s -H Host:workload.site $IP |grep Hello
  done
#  sleep 1
done

#!/bin/bash
IPS="34.226.110.154 52.86.54.186 35.174.150.198"
while true; do
  for IP in $IPS; do
    echo -n "`date` $IP "
    curl -s -H Host:workload.site $IP |grep Hello
  done
#  sleep 1
done

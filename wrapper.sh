#!/bin/bash

fusermount -uz /cfg
/gocfs -ro -d -db cassandra /cfg
N=0
while ! df /cfg | grep gocfs && [ $N -lt 15 ]; do echo "Waiting to cassandra-fs to come up..."; N=$(( $N + 1 )); sleep 1; done
if [ $N -eq 15 ]; then exit 2; fi

if [ -z "$*" ]; then
    bash
else
    $*
fi

#!/bin/bash

echo "test"
ipaddr=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo $ipaddr

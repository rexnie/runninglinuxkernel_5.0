#!/bin/bash

declare -a keyservers=(
    "hkp://keyserver.ubuntu.com:80"
    "keyserver.ubuntu.com"
    "ha.pool.sks-keyservers.net"
    "hkp://ha.pool.sks-keyservers.net:80"
    "p80.pool.sks-keyservers.net"
    "hkp://p80.pool.sks-keyservers.net:80"
    "pgp.mit.edu"
    "hkp://pgp.mit.edu:80"
)

keys=$(apt update 2>&1 | grep -o '[0-9A-Z]\{16\}$')

for key in $keys; do
    for server in "${keyservers[@]}"; do
        echo "Fetching GPG key ${key} from ${server}"
        apt-key adv --keyserver $server --keyserver-options timeout=10 --recv-keys ${key}
        if [ $? -eq 0 ]; then
            echo "Key '${key}' successful added from server '${server}'"
            break
        else
            echo "Failed add key '${key}' from server '${server}'. Try another server"
            continue
        fi
    done
done

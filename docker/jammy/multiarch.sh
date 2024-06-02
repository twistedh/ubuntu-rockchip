#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

if [ "$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)" == "amd64" ]; then
    dpkg --add-architecture arm64
    (
        echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal main restricted"
        echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-updates main restricted"
        echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal universe"
        echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-updates universe"
        echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal multiverse"
        echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-updates multiverse"
        echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-backports main restricted universe multiverse"
        echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-security main restricted"
        echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-security universe"
        echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-security multiverse"
    ) > /etc/apt/sources.list.d/sources.arm64.list
    sed -i "s/deb h/deb [arch=amd64] h/g" /etc/apt/sources.list
    apt-get update
fi

#!/bin/sh

# billthewizard.net
# Install docker on debian, example shell script.

compose_version=$( docker compose version )

case "$compose_version" in
        "") ;;
        *Docker\ Compose*) echo "Docker already installed!"; exit;;
esac

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc
        do sudo apt-get remove $pkg
done

if ! [ -e /etc/apt/keyrings/docker.asc ]
then
        sudo apt-get update
        sudo apt-get install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

if ! [ -e /etc/apt/sources.list.d/docker.list ]
then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
fi

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
    docker-compose-plugin

#!/bin/bash
#
# r5quineinstall.sh
#
# Install Quine Log Parser and Prereqs
#

echo "... updating system ..."
apt update
apt upgrade -y

# fix syslog format
echo "... fixing syslog time format (thanks ubuntu) ..."
sed -i 's/^\$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat/#$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat/g' /etc/rsyslog.conf

# install docker
echo "... installing docker repo ..."
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  apt install -y ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
else
  echo "... docker repo already installed ..."
fi
echo "... installing docker ..."
if [ ! -f /usr/bin/docker ]; then
  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
else
  echo "... docker already installed ..."
fi
echo "... installing docker-compose ..."
if [ ! -f /usr/bin/docker-compose ]; then
  apt update
  apt install -y docker-compose
else
  echo "... docker-compose already installed ..."
fi

# install kafka docker
echo "... installing kafka ..."
docker images | grep kafka
if [ $? -ne 0 ]; then
  docker-compose -f .\kafka-compose.yaml up
  echo "... configuring kafka topic ..."
  docker exec broker \
    kafka-topics --bootstrap-server broker:9092 \
    --create \
    --topic red5prologs
else
  echo "... kafka already installed ..."
fi

# install vector
echo "... installing vector ..."
docker images | grep vector
if [ $? -ne 0 ]; then
  docker pull timberio/vector:0.21.2-distroless-libc
  alias vector='docker run -it --rm timberio/vector:0.21.2'
else
  echo "... vector already installed ..."
fi

# install quine
echo "... installing quine ..."
docker images | grep quine
if [ $? -ne 0 ]; then
  docker pull thatdot/quine
else
  echo "... quine already installed ..."
fi



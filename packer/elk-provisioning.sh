#!/bin/bash -x
set -e
## Add repositories we are going to use
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty main restricted"
add-apt-repository "deb http://packages.elasticsearch.org/logstash/1.4/debian stable main"
add-apt-repository "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main"
add-apt-repository -y ppa:chris-lea/node.js
wget -O - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -

## Update index and install packages
apt-get update
apt-get --yes --force-yes install git wget ruby ruby-dev make ec2-api-tools ec2-ami-tools
apt-get --yes --force-yes install language-pack-en build-essential openjdk-7-jre-headless logstash elasticsearch nodejs

## Install Elasticsearch plugins
/usr/share/elasticsearch/bin/plugin --install elasticsearch/elasticsearch-cloud-aws/2.1.1
/usr/share/elasticsearch/bin/plugin --install mobz/elasticsearch-head
/usr/share/elasticsearch/bin/plugin --install lukas-vlcek/bigdesk
/usr/share/elasticsearch/bin/plugin --install karmi/elasticsearch-paramedic
/usr/share/elasticsearch/bin/plugin --install royrusso/elasticsearch-HQ

## Mount the ephemeral storage on /data
# Create /data
mkdir /data
chown elasticsearch /data

# Move volume from /mnt to /data
umount /mnt
sed -i s#/mnt#/data# /etc/fstab
mount /data

# Set permissions on actual volume
chown elasticsearch /data

## Ensure we don't swap unnecessarily
echo "vm.overcommit_memory=1" > /etc/sysctl.d/70-vm-overcommit

## Install Kibana / Logcabin
(
  cd /opt
  wget -O elk-stack.tar.gz https://github.com/guardian/elk-stack/archive/master.tar.gz
  tar zxvf elk-stack.tar.gz
  mv elk-stack-master/src logcabin
  adduser --disabled-password --gecos "" logcabin
  (
    cd logcabin
    npm install
  )
  chown -R logcabin logcabin

  wget http://download.elasticsearch.org/kibana/kibana/kibana-latest.tar.gz
  tar zxvf kibana-latest.tar.gz
  mv kibana-latest kibana
)

## Download template config files (need to be configured in cloud-init)
wget -O /etc/elasticsearch/elasticsearch.yml.template https://raw.githubusercontent.com/guardian/elk-stack/master/config/elasticsearch.yml
wget -O /opt/logcabin/config.js.template https://raw.githubusercontent.com/guardian/elk-stack/master/config/config.js

## Install upstart configuration
wget -O /etc/init/elasticsearch.conf https://raw.githubusercontent.com/guardian/elk-stack/master/config/upstart-elasticsearch.conf
wget -O /etc/init/logcabin.conf https://raw.githubusercontent.com/guardian/elk-stack/master/config/upstart-logcabin.conf

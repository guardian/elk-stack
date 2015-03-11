#!/bin/bash -x
set -e
## Add repositories we are going to use
add-apt-repository "deb http://packages.elasticsearch.org/logstash/1.4/debian stable main"
add-apt-repository "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main"
add-apt-repository -y ppa:chris-lea/node.js
wget -O - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
sleep 1

## Update index and install packages
apt-get update
apt-get --yes --force-yes install ruby ruby-dev logstash elasticsearch \
    nodejs python-pip

## Install Elasticsearch plugins
/usr/share/elasticsearch/bin/plugin --install elasticsearch/elasticsearch-cloud-aws/2.3.0
/usr/share/elasticsearch/bin/plugin --install mobz/elasticsearch-head
/usr/share/elasticsearch/bin/plugin --install lukas-vlcek/bigdesk
/usr/share/elasticsearch/bin/plugin --install karmi/elasticsearch-paramedic
/usr/share/elasticsearch/bin/plugin --install royrusso/elasticsearch-HQ

## Install logstash config
cp /tmp/config/logstash-indexer.conf /etc/logstash/conf.d/logstash-indexer.conf
sed -i -e 's,@@ELASTICSEARCH,localhost,g' /etc/logstash/conf.d/logstash-indexer.conf

## Install the curator
pip install elasticsearch-curator
# Add script and install crontab
mkdir -p /opt/bin
cp /tmp/config/housekeeping.sh /opt/bin
crontab -u elasticsearch - << EOM
0 1 * * * /bin/bash /opt/bin/housekeeping.sh
EOM

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
  cp -r /tmp/src /opt/logcabin
  adduser --disabled-password --gecos "" logcabin
  (
    cd logcabin
    npm install
  )
  chown -R logcabin logcabin
  # TODO: Fix this ugly hack to convert this to https
  sed -i s#http://#https://# /opt/logcabin/lib/google-oauth.js

  wget http://download.elasticsearch.org/kibana/kibana/kibana-latest.tar.gz
  tar zxvf kibana-latest.tar.gz
  mv kibana-latest kibana
)

## Install the template config files (need to be configured in cloud-init at instance boot)
cp /tmp/config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.template
cp /tmp/config/config.js /opt/logcabin/config.js.template

## Remove existing init.d config for elasticsearch
rm /etc/init.d/elasticsearch
update-rc.d elasticsearch remove

## Install upstart configuration
cp /tmp/config/upstart-elasticsearch.conf /etc/init/elasticsearch.conf
cp /tmp/config/upstart-logcabin.conf /etc/init/logcabin.conf

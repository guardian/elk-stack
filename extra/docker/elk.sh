#!/bin/bash
ES_PID_FILE=$ES_HOME/pidfile
$ES_HOME/bin/elasticsearch -dp $ES_PID_FILE
echo "RUNNING Elastic Search"
#trap 'echo Killing elasticsearch ; kill $(<${ES_PID_FILE})' EXIT
sleep 20
nginx
$LOGSTASH_HOME/bin/logstash agent -f $LOGSTASH_HOME/conf.d 

Dockerfile for Kibana 3
=======================

For example:

	docker build -t elk .
	docker run -ti -P -p 6789:6789 -v $PWD/logstash-tcp.conf:/opt/logstash/conf.d/logstash-tcp.conf elk

Currently the configuration that is applied in the `Dockerfile` is
quite specific to the needs of the Editorial Tools team, and should be
tweaked to become more general.

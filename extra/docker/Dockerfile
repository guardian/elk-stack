FROM archlinux/jre
RUN yes | pacman -Syu
RUN yes | pacman -S nginx
WORKDIR /opt
RUN curl -L https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.3.tar.gz | tar -xzf -
# RUN echo '/opt/elasticsearch-1.4.3/bin/elasticsearch -d' >>/app/elasticsearch.sh
EXPOSE 9200 9292
# COPY logstash-simple.conf /opt/logstash/conf.d/logstash.conf
# COPY kibana-config.js /opt/logstash/vendor/kibana/config.js

# ELASTIC SEARCH

ENV ES_HOME=/opt/elasticsearch-1.4.3/
ENV ES_CONFIG=$ES_HOME/config/elasticsearch.yml
RUN echo 'http.cors.enabled: true' >>$ES_CONFIG
RUN echo 'http.cors.allow-origin: /https?:\/\/.*\.local.dev-gutools.co.uk/' >>$ES_CONFIG

# LOGSTASH

RUN curl -L 'https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz' | tar -xzf -
ENV LOGSTASH_HOME=/opt/logstash-1.4.2
ENV KIBANA_PORT=9292
RUN ln -s $LOGSTASH_HOME /opt/logstash
COPY logstash-simple.conf $LOGSTASH_HOME/conf.d/logstash.conf

# KIBANA
RUN curl -L 'https://download.elasticsearch.org/kibana/kibana/kibana-3.1.1.tar.gz' | tar -xzf -
#RUN curl -L 'https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-linux-x64.tar.gz' | tar -xzf -
RUN curl -L 'http://nodejs.org/dist/v0.12.0/node-v0.12.0-linux-x64.tar.gz' | tar -xzf -
RUN ln -s /opt/node-v0.12.0-linux-x64 $KIBANA_HOME/node
ENV KIBANA_HOME=/opt/kibana-3.1.1
ENV KIBANA_CONF_FILE=$KIBANA_HOME/config.js
RUN sed -i.orig -e 's@^\(\s*elasticsearch:\s*\)\(.*\),@\1"https://elasticsearch.local.dev-gutools.co.uk",@' \
  -e 's@^\(\s*port:\s*\)\(.*\)@\1'${KIBANA_PORT}'@' \
  $KIBANA_CONF_FILE
COPY nginx/kibana.conf /etc/nginx/nginx.conf 
# APP START SCRIPT
COPY elk.sh /
CMD /elk.sh 

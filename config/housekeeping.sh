#!/bin/bash
# Cleanup indexes
/usr/local/bin/curator --logformat logstash delete --older-than 7 2>&1 | /bin/nc localhost 28778
# Optimise older indexes
/usr/local/bin/curator --logformat logstash bloom --older-than 1 2>&1 | /bin/nc localhost 28778
/usr/local/bin/curator --logformat logstash optimize --older-than 1 2>&1 | /bin/nc localhost 28778

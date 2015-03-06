#!/bin/bash
# Cleanup indexes
/usr/local/bin/curator --logformat logstash delete --older-than 7 | /bin/nc localhost 28778
# Optimise older indexes
/usr/local/bin/curator --logformat logstash bloom --older-than 1 | /bin/nc localhost 28778
/usr/local/bin/curator --logformat logstash optimise --older-than 1 | /bin/nc localhost 28778

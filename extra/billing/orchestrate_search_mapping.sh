#!/bin/bash

# Default search mapping for dashboard to work
curl -XPUT "http://localhost:9200/.kibana/_mappings/search" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/discover_search.json`"

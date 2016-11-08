#!/bin/bash

#Import the default AWS-Billing-DashBoard json file if there is no such dashboard present

CONTENT=`curl -XGET "http://localhost:9200/.kibana/dashboard/AWS-Billing-DashBoard"`;

if [[ $CONTENT == *'"found":true'* ]]
then
    echo "Dashboard With Default Name Is Already There!";
else
    echo "Default Dashboard Is Being Created!";
    curl -XPUT "http://localhost:9200/.kibana/dashboard/AWS-Billing-DashBoard" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/kibana_dashboard.json`";
fi

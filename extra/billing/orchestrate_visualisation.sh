#!/bin/bash

#Import visualisation json file if that doesn't exist
CONTENT=`curl -XGET "http://localhost:9200/.kibana/visualization/finalVisualization_5days_30min_row_split"`;
if [[ $CONTENT == *'"found":false'* ]]
then
    curl -XPUT "http://localhost:9200/.kibana/visualization/finalVisualization_5days_30min_row_split" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/finalVisualization_5days_30min_row_split.json`";
fi


CONTENT=`curl -XGET "http://localhost:9200/.kibana/visualization/finalVisualization_5days_30min_line_split"`;
if [[ $CONTENT == *'"found":false'* ]]
then
    curl -XPUT "http://localhost:9200/.kibana/visualization/finalVisualization_5days_30min_line_split" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/finalVisualization_5days_30min_line_split.json`";
fi


CONTENT=`curl -XGET "http://localhost:9200/.kibana/visualization/api_call_table"`;
if [[ $CONTENT == *'"found":false'* ]]
then
    curl -XPUT "http://localhost:9200/.kibana/visualization/api_call_table" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/api_call_table.json`";
fi


CONTENT=`curl -XGET "http://localhost:9200/.kibana/visualization/Total_UnblendedCost"`;
if [[ $CONTENT == *'"found":false'* ]]
then
    curl -XPUT "http://localhost:9200/.kibana/visualization/Total_UnblendedCost" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/Total_UnblendedCost.json`";
fi


CONTENT=`curl -XGET "http://localhost:9200/.kibana/visualization/Spot_vs_OnDemand_EC2"`;
if [[ $CONTENT == *'"found":false'* ]]
then
    curl -XPUT "http://localhost:9200/.kibana/visualization/Spot_vs_OnDemand_EC2" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/Spot_vs_OnDemand_EC2.json`";
fi


CONTENT=`curl -XGET "http://localhost:9200/.kibana/visualization/Split_bars_daily"`;
if [[ $CONTENT == *'"found":false'* ]]
then
    curl -XPUT "http://localhost:9200/.kibana/visualization/Split_bars_daily" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/Split_bars_daily.json`";
fi


CONTENT=`curl -XGET "http://localhost:9200/.kibana/visualization/S3_Api_Calls_daily"`;
if [[ $CONTENT == *'"found":false'* ]]
then
    curl -XPUT "http://localhost:9200/.kibana/visualization/S3_Api_Calls_daily" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/S3_Api_Calls_daily.json`";
fi


CONTENT=`curl -XGET "http://localhost:9200/.kibana/visualization/Pi-chart-for-seperate-services"`;
if [[ $CONTENT == *'"found":false'* ]]
then
    curl -XPUT "http://localhost:9200/.kibana/visualization/Pi-chart-for-seperate-services" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/Pi-chart-for-seperate-services.json`";
fi


CONTENT=`curl -XGET "http://localhost:9200/.kibana/visualization/Cost_For_AmazonS3_requests"`;
if [[ $CONTENT == *'"found":false'* ]]
then
    curl -XPUT "http://localhost:9200/.kibana/visualization/Cost_For_AmazonS3_requests" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/Cost_For_AmazonS3_requests.json`";
fi


CONTENT=`curl -XGET "http://localhost:9200/.kibana/visualization/Top-5-used-service-split-daily"`;
if [[ $CONTENT == *'"found":false'* ]]
then
    curl -XPUT "http://localhost:9200/.kibana/visualization/Top-5-used-service-split-daily" -d "`curl https://raw.githubusercontent.com/toadkicker/elk-stack/master/extra/billing/top_5_used_service_split_daily.json`";
fi

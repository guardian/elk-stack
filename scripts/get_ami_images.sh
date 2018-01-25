#!/bin/sh

AMI_IMAGE_NAME="ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180122"

# http://docs.aws.amazon.com/general/latest/gr/rande.html#ec2_region

for region in us-east-1 us-west-2 us-west-1 eu-west-1 eu-west-2 eu-central-1 ap-southeast-1 ap-northeast-1 ap-southeast-2 ap-northeast-2 sa-east-1
do
    printf "    $region:\n"
    IMAGE_ID=`aws ec2 describe-images --filters Name=name,Values=$AMI_IMAGE_NAME --region $region | jq .Images[].ImageId`
    printf "      ImageId: ${IMAGE_ID//\"}\n"
done

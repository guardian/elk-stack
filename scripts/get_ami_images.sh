#!/bin/sh

AMI_IMAGE_NAME="*ubuntu/images/ebs/ubuntu-trusty-14.04-amd64-server-20140607.1"

# http://docs.aws.amazon.com/general/latest/gr/rande.html#ec2_region

for region in us-east-1 us-west-2 us-west-1 eu-west-1 eu-central-1 ap-southeast-1 ap-southeast-2 ap-northeast-1 sa-east-1
do
    printf "\"$region\" : {"
    aws ec2 describe-images --filters Name=name,Values=$AMI_IMAGE_NAME --region $region | grep "ImageId" | sed s/,// | tr -d '\n'
    printf "},\n"
done

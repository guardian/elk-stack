#!/bin/bash
# Build packer AMI (on TeamCity host)

# die if any command fails
set -e

# set PACKER_HOME if it isn't already provided
[ -z "${PACKER_HOME}" ] && PACKER_HOME=/opt/packer

# ensure that we have AWS credentials (configure in TeamCity normally)
# note that we don't actually use them in the script, the packer command does
if [ -z "${AWS_ACCESS_KEY}" -o -z "${AWS_SECRET_KEY}" ]
then
  echo "AWS_ACCESS_KEY and AWS_SECRET_KEY environment variables must be set" > &2
  exit 1
fi

# now build
echo "Building ELK AMI"
${PACKER_HOME}/packer build -color=false elk.json

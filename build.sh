#!/bin/bash
# Build packer AMI (on TeamCity host)

# die if any command fails
set -e

# set PACKER_HOME if it isn't already provided
[ -z "${PACKER_HOME}" ] && PACKER_HOME="/opt/packer"

# set BUILD_NUMBER to DEV if not in TeamCity
[ -z "${BUILD_NUMBER}" ] && BUILD_NUMBER="DEV"

# set BUILD_BRANCH if not in TeamCity
[ -z "${BUILD_BRANCH}" ] && BUILD_BRANCH="DEV"

# set BUILD_NUMBER to DEV if not in TeamCity
BUILD_NAME=${TEAMCITY_PROJECT_NAME}-${TEAMCITY_BUILDCONF_NAME}
[ -z "${TEAMCITY_BUILDCONF_NAME}" -o -z "${TEAMCITY_PROJECT_NAME}" ] && BUILD_NAME="unknown"

# ensure that we have AWS credentials (configure in TeamCity normally)
# note that we don't actually use them in the script, the packer command does
if [ -z "${AWS_ACCESS_KEY}" -o -z "${AWS_SECRET_KEY}" ]
then
  echo "AWS_ACCESS_KEY and AWS_SECRET_KEY environment variables must be set" 1>&2
  exit 1
fi

# Get all the account numbers of our AWS accounts
PRISM_JSON=$(curl -s "http://prism.gutools.co.uk/sources?resource=instance&origin.vendor=aws")
ACCOUNT_NUMBERS=$(echo ${PRISM_JSON} | jq '.data[].origin.accountNumber' | tr '\n' ',' | sed s/\"//g | sed s/,$//)
echo "Account numbers for AMI: $ACCOUNT_NUMBERS"

# now build
echo "Building ELK AMI" 1>&2
${PACKER_HOME}/packer build -color=false \
  -var "build_number=${BUILD_NUMBER}" -var "build_name=${BUILD_NAME}" \
  -var "build_branch=${BUILD_BRANCH}" -var "account_numbers=${ACCOUNT_NUMBERS}" \
  packer/elk.json

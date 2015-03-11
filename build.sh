#!/bin/bash
set -e
pushd packer
bash build.sh
popd
